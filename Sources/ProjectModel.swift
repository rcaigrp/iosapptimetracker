import Foundation

struct Project: Codable, Identifiable {
    let id = UUID()
    let name: String
    let createdAt: Date
}

struct ProjectList: Codable {
    var projects: [Project]
}