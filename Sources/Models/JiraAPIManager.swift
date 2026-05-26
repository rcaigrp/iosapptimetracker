// MARK: - Jira API Manager
import Foundation
import Security

@MainActor
class JiraAPIManager: ObservableObject {
    @Published var isAuthorized = false
    private var baseURL: String?
    private var apiToken: String?
    
    // MARK: - Credentials Management
    func saveCredentials(baseURL: String, apiToken: String) {
        self.baseURL = baseURL
        self.apiToken = apiToken
        isAuthorized = true
        
        // Store in Keychain (simplified implementation)
        storeInKeychain(key: "jira_base_url", value: baseURL)
        storeInKeychain(key: "jira_api_token", value: apiToken)
    }
    
    func loadCredentials() {
        guard let baseURL = loadFromKeychain(key: "jira_base_url"),
              let apiToken = loadFromKeychain(key: "jira_api_token") else {
            isAuthorized = false
            return
        }
        
        self.baseURL = baseURL
        self.apiToken = apiToken
        isAuthorized = true
    }
    
    func clearCredentials() {
        deleteFromKeychain(key: "jira_base_url")
        deleteFromKeychain(key: "jira_api_token")
        baseURL = nil
        apiToken = nil
        isAuthorized = false
    }
    
    // MARK: - Keychain Helpers
    private func storeInKeychain(key: String, value: String) {
        // Simplified keychain storage - in real implementation would use proper Security framework calls
        UserDefaults.standard.set(value, forKey: key)
    }
    
    private func loadFromKeychain(key: String) -> String? {
        return UserDefaults.standard.string(forKey: key)
    }
    
    private func deleteFromKeychain(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    // MARK: - Jira API Calls
    func fetchProjects() async throws -> [JiraProject] {
        guard let baseURL = baseURL, let apiToken = apiToken else {
            throw JiraAPIError.unauthorized
        }
        
        let url = URL(string: "\(baseURL)/rest/api/3/project")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Basic \(Data("\(apiToken):".utf8).base64EncodedString())", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw JiraAPIError.networkError
        }
        
        if httpResponse.statusCode != 200 {
            throw JiraAPIError.invalidResponse(statusCode: httpResponse.statusCode)
        }
        
        do {
            return try JSONDecoder().decode([JiraProject].self, from: data)
        } catch {
            throw JiraAPIError.decodingError
        }
    }
}

// MARK: - Error Handling
enum JiraAPIError: Error, LocalizedError {
    case unauthorized
    case networkError
    case invalidResponse(statusCode: Int)
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "Jira credentials required"
        case .networkError:
            return "Network error occurred"
        case .invalidResponse(let statusCode):
            return "Invalid response from Jira API (\(statusCode))"
        case .decodingError:
            return "Failed to decode Jira API response"
        }
    }
}

// MARK: - Jira Project Model
struct JiraProject: Codable, Identifiable {
    let id: String
    let key: String
    let name: String
    let avatarUrls: [String: String]
}