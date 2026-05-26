// NetworkManager.swift
import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    // MARK: - API Configuration
    struct APIError: Error, LocalizedError {
        let message: String
        
        var errorDescription: String? { message }
    }
    
    // MARK: - Rate Limiting
    private var rateLimitResetTime: Date?
    private var requestCount = 0
    private let maxRequestsPerWindow = 1000
    private let timeWindow: TimeInterval = 3600 // 1 hour
    
    // MARK: - Jira Credentials
    func saveCredentials(baseURL: String, apiToken: String) {
        // In a real implementation, this would use Keychain Services
        // For now, storing in UserDefaults for demonstration
        UserDefaults.standard.set(baseURL, forKey: "JiraBaseURL")
        UserDefaults.standard.set(apiToken, forKey: "JiraAPIToken")
    }
    
    func getCachedCredentials() -> (baseURL: String, apiToken: String)? {
        guard let baseURL = UserDefaults.standard.string(forKey: "JiraBaseURL"),
              let apiToken = UserDefaults.standard.string(forKey: "JiraAPIToken") else {
            return nil
        }
        return (baseURL: baseURL, apiToken: apiToken)
    }
    
    // MARK: - API Calls
    func fetchProjects(completion: @escaping (Result<[Project], Error>) -> Void) {
        guard let credentials = getCachedCredentials() else {
            completion(.failure(APIError(message: "Missing Jira credentials")))
            return
        }
        
        let url = URL(string: "\(credentials.baseURL)/rest/api/3/project")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Basic \(Data("\(credentials.apiToken):".utf8).base64EncodedString())", forHTTPHeaderField: "Authorization")
        
        performRequest(request: request) { result in
            switch result {
            case .success(let data):
                do {
                    let projects = try JSONDecoder().decode([Project].self, from: data)
                    completion(.success(projects))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchIssues(projectKey: String, completion: @escaping (Result<[Issue], Error>) -> Void) {
        guard let credentials = getCachedCredentials() else {
            completion(.failure(APIError(message: "Missing Jira credentials")))
            return
        }
        
        let url = URL(string: "\(credentials.baseURL)/rest/api/3/search?jql=project='\(projectKey)'&maxResults=100")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Basic \(Data("\(credentials.apiToken):".utf8).base64EncodedString())", forHTTPHeaderField: "Authorization")
        
        performRequest(request: request) { result in
            switch result {
            case .success(let data):
                do {
                    let issues = try JSONDecoder().decode(IssuesResponse.self, from: data)
                    completion(.success(issues.issues))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Core Request Logic
    private func performRequest(request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) {
        // Check rate limit status
        if let resetTime = rateLimitResetTime, Date() < resetTime {
            // Wait until rate limit resets
            DispatchQueue.main.asyncAfter(deadline: .now() + resetTime.timeIntervalSinceNow) {
                self.performRequest(request: request, completion: completion)
            }
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle network errors
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            // Check for rate limit headers
            if let httpResponse = response as? HTTPURLResponse {
                self.handleRateLimitHeaders(httpResponse)
                
                // Handle HTTP errors
                if httpResponse.statusCode >= 400 {
                    DispatchQueue.main.async {
                        completion(.failure(APIError(message: "HTTP \(httpResponse.statusCode)")))
                    }
                    return
                }
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(APIError(message: "No data received")))
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(.success(data))
            }
        }
        
        task.resume()
    }
    
    private func handleRateLimitHeaders(_ response: HTTPURLResponse) {
        // Check for rate limit reset header
        if let resetTimeString = response.allHeaderFields["X-RateLimit-Reset"] as? String,
           let resetTime = Int(resetTimeString) {
            self.rateLimitResetTime = Date(timeIntervalSince1970: TimeInterval(resetTime))
        }
        
        // Update request count
        requestCount += 1
        
        // Reset counter after time window
        if let resetTime = rateLimitResetTime,
           Date().timeIntervalSince(resetTime) > timeWindow {
            requestCount = 0
        }
    }
}

// MARK: - Data Models
struct Project: Codable {
    let id: String
    let key: String
    let name: String
}

struct Issue: Codable {
    let id: String
    let key: String
    let summary: String
    let status: Status
}

struct Status: Codable {
    let name: String
}

struct IssuesResponse: Codable {
    let issues: [Issue]
}