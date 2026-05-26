import SwiftData

@Model
final class TimeEntry {
    var projectName: String
    var startTime: Date
    var endTime: Date?
    var duration: TimeInterval = 0
    
    init(projectName: String, startTime: Date) {
        self.projectName = projectName
        self.startTime = startTime
    }
}