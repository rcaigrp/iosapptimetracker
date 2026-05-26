// JiraAPIClient.swift
import Foundation

class JiraAPIClient {
    static let shared = JiraAPIClient()
    
    private init() {}
    
    // MARK: - Public Methods
    func authenticate(baseURL: String, apiToken: String, completion: @escaping (Result<Void, Error>) -> Void) {
        NetworkManager.shared.saveCredentials(baseURL: baseURL, apiToken: apiToken)
        
        // Test authentication by fetching projects
        NetworkManager.shared.fetchProjects { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchProjects(completion: @escaping (Result<[Project], Error>) -> Void) {
        NetworkManager.shared.fetchProjects(completion: completion)
    }
    
    func fetchIssues(for projectKey: String, completion: @escaping (Result<[Issue], Error>) -> Void) {
        NetworkManager.shared.fetchIssues(projectKey: projectKey, completion: completion)
    }
}