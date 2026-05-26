import Foundation

class TimeEntry: Codable, Identifiable {
    let id = UUID()
    let project: Project
    let startTime: Date
    var endTime: Date?
    var notes: String?
    
    var duration: TimeInterval {
        if let endTime = endTime {
            return endTime.timeIntervalSince(startTime)
        }
        return Date().timeIntervalSince(startTime)
    }
}