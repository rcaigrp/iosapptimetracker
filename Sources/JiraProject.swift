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