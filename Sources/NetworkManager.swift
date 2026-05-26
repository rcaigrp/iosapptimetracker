import Foundation

public class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    public func performRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
        return try await withCheckedThrowingContinuation { continuation in
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let data = data, let response = response else {
                    continuation.resume(throwing: URLError(.badServerResponse))
                    return
                }
                
                continuation.resume(returning: (data, response))
            }
            task.resume()
        }
    }
}
