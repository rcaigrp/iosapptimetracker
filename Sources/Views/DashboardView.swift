import SwiftUI

struct DashboardView: View {
    @State private var isTimerRunning = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    
    @Query(
        .all(Project.self)
    ) private var projects: [Project]
    
    @State private var projectName = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Timer Section
                VStack {
                    Text("Timer")
                        .font(.headline)
                    Text(formatTime(elapsedTime))
                        .font(.title2)
                        .padding()
                    
                    HStack {
                        Button(action: startTimer) {
                            Text("Start")
                                .frame(maxWidth: .infinity)
                        }
                        .disabled(isTimerRunning)
                        
                        Button(action: pauseTimer) {
                            Text("Pause")
                                .frame(maxWidth: .infinity)
                        }
                        .disabled(!isTimerRunning)
                        
                        Button(action: stopTimer) {
                            Text("Stop")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // Project Creation
                VStack {
                    Text("Create New Project")
                        .font(.headline)
                    TextField("Project Name", text: $projectName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Button(action: createProject) {
                        Text("Add Project")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // Projects List
                VStack {
                    Text("Projects")
                        .font(.headline)
                    if projects.isEmpty {
                        Text("No projects yet")
                            .foregroundColor(.secondary)
                    } else {
                        List(projects, id: \Project.id) { project in
                            Text(project.name)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Time Tracker")
        }
    }
    
    private func startTimer() {
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            elapsedTime += 1
        }
    }
    
    private func pauseTimer() {
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    private func stopTimer() {
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
        elapsedTime = 0
    }
    
    private func createProject() {
        if !projectName.isEmpty {
            // In a real implementation, this would save to SwiftData
            projectName = ""
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

#Preview {
    DashboardView()
}