import Foundation

class JiraAPI {
    private let baseURL: String
    private let apiToken: String
    
    init(baseURL: String, apiToken: String) {
        self.baseURL = baseURL
        self.apiToken = apiToken
    }
    
    func fetchProjects(completion: @escaping (Result<[String], Error>) -> Void) {
        // Mock implementation - in real app this would make network calls
        DispatchQueue.main.async {
            completion(.success(["Project A", "Project B", "Project C"]))
        }
    }
}