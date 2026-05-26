// MARK: - Jira API Manager
import Foundation
import SwiftData

class JiraAPIManager: ObservableObject {
    static let shared = JiraAPIManager()
    
    @Published var projects: [JiraProject] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    private init() {}
    
    // MARK: - API Configuration
    struct JiraCredentials {
        let baseURL: String
        let apiToken: String
        let email: String
        
        func getAuthHeader() -> String {
            let credentials = "\(email):\(apiToken)"
            let data = credentials.data(using: .utf8)!
            return data.base64EncodedString()
        }
    }
    
    private var credentials: JiraCredentials? {
        get {
            guard let savedBaseURL = UserDefaults.standard.string(forKey: "JiraBaseURL"),
                  let savedEmail = UserDefaults.standard.string(forKey: "JiraEmail"),
                  let savedToken = UserDefaults.standard.string(forKey: "JiraAPIToken") else {
                return nil
            }
            return JiraCredentials(baseURL: savedBaseURL, apiToken: savedToken, email: savedEmail)
        }
        set {
            if let creds = newValue {
                UserDefaults.standard.set(creds.baseURL, forKey: "JiraBaseURL")
                UserDefaults.standard.set(creds.email, forKey: "JiraEmail")
                UserDefaults.standard.set(creds.apiToken, forKey: "JiraAPIToken")
            } else {
                UserDefaults.standard.removeObject(forKey: "JiraBaseURL")
                UserDefaults.standard.removeObject(forKey: "JiraEmail")
                UserDefaults.standard.removeObject(forKey: "JiraAPIToken")
            }
        }
    }
    
    // MARK: - Credential Management
    func saveCredentials(baseURL: String, email: String, apiToken: String) {
        credentials = JiraCredentials(baseURL: baseURL, apiToken: apiToken, email: email)
    }
    
    func clearCredentials() {
        credentials = nil
    }
    
    func hasValidCredentials() -> Bool {
        return credentials != nil
    }
    
    // MARK: - Rate Limiting
    private var requestTimestamps: [String] = []
    private let maxRequestsPerMinute = 300
    
    private func isRateLimited() -> Bool {
        let now = Date()
        let oneMinuteAgo = now.addingTimeInterval(-60)
        
        // Remove old timestamps
        requestTimestamps = requestTimestamps.filter { $0 > oneMinuteAgo }
        
        return requestTimestamps.count >= maxRequestsPerMinute
    }
    
    private func recordRequest() {
        requestTimestamps.append(Date())
    }
    
    // MARK: - API Calls
    func fetchProjects() async throws -> [JiraProject] {
        guard let credentials = self.credentials else {
            throw JiraAPIError.missingCredentials
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Check rate limiting
            if isRateLimited() {
                try await Task.sleep(nanoseconds: 1_000_000_000) // Wait 1 second
            }
            
            let url = URL(string: "\(credentials.baseURL)/rest/api/3/project")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Basic \(credentials.getAuthHeader())", forHTTPHeaderField: "Authorization")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    recordRequest()
                    let projects = try JSONDecoder().decode([JiraProject].self, from: data)
                    isLoading = false
                    return projects
                case 429:
                    // Handle rate limiting
                    throw JiraAPIError.rateLimited
                default:
                    throw JiraAPIError.httpError(statusCode: httpResponse.statusCode)
                }
            }
            
            throw JiraAPIError.unknown
        } catch {
            isLoading = false
            throw error
        }
    }
}

// MARK: - Error Handling
enum JiraAPIError: Error, LocalizedError {
    case missingCredentials
    case rateLimited
    case httpError(statusCode: Int)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .missingCredentials:
            return "Jira credentials are required. Please enter your Jira API credentials in Settings."
        case .rateLimited:
            return "Rate limit exceeded. Please wait before making more requests."
        case .httpError(let statusCode):
            return "HTTP Error \(statusCode)"
        case .unknown:
            return "An unknown error occurred while communicating with Jira API."
        }
    }
}

// MARK: - Data Models
struct JiraProject: Codable, Identifiable {
    let id: String
    let key: String
    let name: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        key = try container.decode(String.self, forKey: .key)
        name = try container.decode(String.self, forKey: .name)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, key, name
    }
}