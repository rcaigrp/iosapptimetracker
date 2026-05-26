import Foundation

class JiraAPIManager {
    func fetchIssues(completion: @escaping (Result<[String], Error>) -> Void) {
        // Mock implementation
        completion(.success(["Issue 1", "Issue 2", "Issue 3"]))
    }
}