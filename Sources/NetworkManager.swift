import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    func fetchProjects(completion: @escaping (Result<[Project], Error>) -> Void) {
        // Implementation for fetching projects from Jira API
    }
}