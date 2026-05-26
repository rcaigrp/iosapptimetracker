import Foundation

struct Project: Codable, Identifiable {
    let id = UUID()
    let name: String
    let key: String
}