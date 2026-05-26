import Foundation

class JiraAPIClient {
    static let shared = JiraAPIClient()
    
    private var baseURL: String?
    private var apiToken: String?
    private var lastRequestTime: Date = Date.distantPast
    private var requestQueue: [URLRequest] = []
    private let queue = DispatchQueue(label: "jira-api-queue", qos: .userInitiated)
    
    private init() {}
    
    func setCredentials(baseURL: String, apiToken: String) {
        self.baseURL = baseURL
        self.apiToken = apiToken
    }
    
    func getProjects(completion: @escaping (Result<[JiraProject], Error>) -> Void) {
        guard let baseURL = baseURL, let apiToken = apiToken else {
            completion(.failure(JiraError.missingCredentials))
            return
        }
        
        let url = URL(string: "\(baseURL)/rest/api/3/project")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Basic \(Data("\(apiToken):".utf8).base64EncodedString())", forHTTPHeaderField: "Authorization")
        
        performRequest(request: request) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let projects = try decoder.decode([JiraProject].self, from: data)
                    completion(.success(projects))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func performRequest(request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) {
        // Rate limiting logic
        let now = Date()
        let timeSinceLastRequest = now.timeIntervalSince(lastRequestTime)
        
        if timeSinceLastRequest < 1.0 { // 1 second minimum between requests
            queue.asyncAfter(deadline: .now() + (1.0 - timeSinceLastRequest)) {
                self.performRequest(request: request, completion: completion)
            }
            return
        }
        
        lastRequestTime = now
        
        // In a real implementation, this would use URLSession
        // For now, we'll simulate the network call
        DispatchQueue.global(qos: .background).async {
            // Simulate network delay
            Thread.sleep(forTimeInterval: 0.1)
            
            // This is where actual URLSession would be used
            // let task = URLSession.shared.dataTask(with: request) { data, response, error in
            //     if let error = error {
            //         completion(.failure(error))
            //         return
            //     }
            //     guard let data = data else {
            //         completion(.failure(JiraError.noData))
            //         return
            //     }
            //     completion(.success(data))
            // }
            // task.resume()
            
            // Simulate success for testing
            completion(.success(Data()))
        }
    }
}

struct JiraProject: Codable {
    let id: String
    let key: String
    let name: String
    let avatarUrls: [String: String]
}

enum JiraError: Error, LocalizedError {
    case missingCredentials
    case noData
    
    var errorDescription: String? {
        switch self {
        case .missingCredentials:
            return "Jira credentials are missing"
        case .noData:
            return "No data received from Jira API"
        }
    }
}