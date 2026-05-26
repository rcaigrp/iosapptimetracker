import Foundation
import SwiftData

@Model
class TimeEntry {
    var project: Project?
    var startTime: Date
    var endTime: Date?
    var duration: TimeInterval = 0
    var notes: String?
    
    init(project: Project?, startTime: Date = Date()) {
        self.project = project
        self.startTime = startTime
    }
}