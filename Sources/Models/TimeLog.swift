// MARK: - Time Log Model
import Foundation
import SwiftData

@Model
class TimeLog {
    var projectKey: String
    var projectName: String
    var startTime: Date
    var endTime: Date?
    var duration: TimeInterval = 0
    var notes: String?
    
    init(projectKey: String, projectName: String, startTime: Date = Date(), notes: String? = nil) {
        self.projectKey = projectKey
        self.projectName = projectName
        self.startTime = startTime
        self.notes = notes
    }
    
    func stopTimer() {
        guard let endTime = endTime else { return }
        duration = endTime.timeIntervalSince(startTime)
    }
}