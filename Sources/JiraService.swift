// MARK: - Jira API Client

class JiraService {
    private let baseURL: String
    private let apiToken: String
    private let username: String
    
    init(baseURL: String, username: String, apiToken: String) {
        self.baseURL = baseURL
        self.username = username
        self.apiToken = apiToken
    }
    
    // MARK: - Project Fetching with Rate Limit Handling
    
    func fetchProjects(completion: @escaping (Result<[JiraProject], Error>) -> Void) {
        let url = URL(string: "\(baseURL)/rest/api/3/project/search")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(JiraError.invalidResponse))
                return
            }
            
            // Handle rate limiting
            if httpResponse.statusCode == 429 {
                self.handleRateLimit(response: httpResponse, completion: completion)
                return
            }
            
            guard let data = data else {
                completion(.failure(JiraError.noData))
                return
            }
            
            do {
                let projectsResponse = try JSONDecoder().decode(JiraProjectsResponse.self, from: data)
                completion(.success(projectsResponse.projects))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    // MARK: - Rate Limit Handling
    
    private func handleRateLimit(response: HTTPURLResponse, completion: @escaping (Result<[JiraProject], Error>) -> Void) {
        guard let resetHeader = response.allHeaderFields["X-RateLimit-Reset"] as? String,
              let resetTime = Int(resetHeader) else {
            completion(.failure(JiraError.rateLimitParseError))
            return
        }
        
        // Calculate delay (add 1 second buffer)
        let delay = DispatchTimeInterval.seconds(max(1, resetTime - Int(Date().timeIntervalSince1970)))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.fetchProjects(completion: completion)
        }
    }
    
    private var base64Credentials: String {
        let credentials = "\(username):\(apiToken)"
        return Data(credentials.utf8).base64EncodedString()
    }
}

// MARK: - Error Types

enum JiraError: Error, LocalizedError {
    case invalidResponse
    case noData
    case rateLimitParseError
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid HTTP response"
        case .noData:
            return "No data received from server"
        case .rateLimitParseError:
            return "Failed to parse rate limit header"
        }
    }
}

// MARK: - Jira Project Model

class JiraProject: Codable {
    let id: String
    let key: String
    let name: String
    
    init(id: String, key: String, name: String) {
        self.id = id
        self.key = key
        self.name = name
    }
}

// MARK: - Response Model

class JiraProjectsResponse: Codable {
    let projects: [JiraProject]
    
    init(projects: [JiraProject]) {
        self.projects = projects
    }
}