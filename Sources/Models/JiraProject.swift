import Foundation

struct JiraProject: Codable, Identifiable {
    let id: String
    let key: String
    let name: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        key = try container.decode(String.self, forKey: .key)
        name = try container.decode(String.self, forKey: .name)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, key, name
    }
}