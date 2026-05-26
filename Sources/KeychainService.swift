import Foundation
import Security

class KeychainService {
    static let shared = KeychainService()
    
    private init() {}
    
    func saveCredentials(baseURL: String, apiToken: String) -> Bool {
        // Delete existing
        deleteCredentials()
        
        // Save new credentials
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "jira_base_url",
            kSecValueData as String: baseURL.data(using: .utf8)!
        ]
        
        let query2: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "jira_api_token",
            kSecValueData as String: apiToken.data(using: .utf8)!
        ]
        
        let status1 = SecItemAdd(query as CFDictionary, nil)
        let status2 = SecItemAdd(query2 as CFDictionary, nil)
        
        return status1 == errSecSuccess && status2 == errSecSuccess
    }
    
    func loadCredentials() -> (baseURL: String?, apiToken: String?) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "jira_base_url",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        let query2: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "jira_api_token",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status1 = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        var dataTypeRef2: AnyObject?
        let status2 = SecItemCopyMatching(query2 as CFDictionary, &dataTypeRef2)
        
        let baseURL = status1 == errSecSuccess ? String(data: dataTypeRef as! Data, encoding: .utf8) : nil
        let apiToken = status2 == errSecSuccess ? String(data: dataTypeRef2 as! Data, encoding: .utf8) : nil
        
        return (baseURL, apiToken)
    }
    
    func deleteCredentials() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "jira_base_url"
        ]
        
        let query2: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "jira_api_token"
        ]
        
        SecItemDelete(query as CFDictionary)
        SecItemDelete(query2 as CFDictionary)
    }
}