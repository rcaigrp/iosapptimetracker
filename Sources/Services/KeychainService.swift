import Foundation

class KeychainService {
    static let shared = KeychainService()
    
    private init() {}
    
    func saveCredentials(baseURL: String, apiToken: String) {
        // Implementation for saving credentials securely
    }
    
    func loadCredentials() -> (baseURL: String, apiToken: String)? {
        // Implementation for loading credentials
        return nil
    }
}