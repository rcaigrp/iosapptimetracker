import Foundation

public struct JiraProject: Codable, Identifiable {
    public let id: String
    public let key: String
    public let name: String
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case key = "key"
        case name = "name"
    }
}

public class JiraAPIService {
    private let networkManager = NetworkManager.shared
    private var baseUrl: String?
    private var apiToken: String?
    
    public init() {}
    
    public func configure(baseUrl: String, apiToken: String) {
        self.baseUrl = baseUrl
        self.apiToken = apiToken
    }
    
    public func fetchProjects() async throws -> [JiraProject] {
        guard let baseUrl = baseUrl, let apiToken = apiToken else {
            throw JiraAPIError.missingCredentials
        }
        
        guard var urlComponents = URLComponents(string: "\(baseUrl)/rest/api/3/project") else {
            throw URLError(.badURL)
        }
        
        let request = makeRequest(url: urlComponents.url!, method: "GET")
        
        return try await withExponentialBackoff(maxRetries: 3) { 
            let (data, response) = try await networkManager.performRequest(request)
            
            if let httpResponse = response as? HTTPURLResponse {
                // Handle rate limiting
                if httpResponse.statusCode == 429 {
                    throw JiraAPIError.rateLimitExceeded
                }
                
                if httpResponse.statusCode == 401 {
                    throw JiraAPIError.unauthorized
                }
                
                if httpResponse.statusCode >= 400 {
                    throw JiraAPIError.serverError(statusCode: httpResponse.statusCode)
                }
            }
            
            return try JSONDecoder().decode([JiraProject].self, from: data)
        }
    }
    
    private func makeRequest(url: URL, method: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Basic \(Data("\(apiToken):".utf8).base64EncodedString())", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return request
    }
    
    private func withExponentialBackoff<T>(maxRetries: Int, operation: @escaping () async throws -> T) async throws -> T {
        var attempts = 0
        let baseDelay: TimeInterval = 1.0
        
        while true {
            do {
                return try await operation()
            } catch JiraAPIError.rateLimitExceeded {
                attempts += 1
                if attempts > maxRetries {
                    throw JiraAPIError.rateLimitExceeded
                }
                
                let delay = baseDelay * pow(2, Double(attempts - 1))
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            } catch {
                throw error
            }
        }
    }
}

public enum JiraAPIError: Error, LocalizedError {
    case missingCredentials
    case rateLimitExceeded
    case unauthorized
    case serverError(statusCode: Int)
    
    public var errorDescription: String? {
        switch self {
        case .missingCredentials:
            return "Jira credentials are not configured"
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please try again later."
        case .unauthorized:
            return "Authentication failed. Please check your API token."
        case .serverError(let statusCode):
            return "Server error: \(statusCode)"
        }
    }
}
