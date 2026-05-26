import SwiftUI

class TimerViewModel: ObservableObject {
    @Published var isRunning = false
    @Published var elapsedTime = 0
    
    private var timer: Timer?
    
    func start() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.elapsedTime += 1
        }
    }
    
    func stop() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func reset() {
        stop()
        elapsedTime = 0
    }
}

struct TimerView: View {
    @StateObject private var viewModel = TimerViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Elapsed Time: \(viewModel.elapsedTime)s")
                .font(.title)
            
            HStack(spacing: 20) {
                Button(action: viewModel.start) {
                    Text("Start")
                }
                .disabled(viewModel.isRunning)
                
                Button(action: viewModel.stop) {
                    Text("Stop")
                }
                .disabled(!viewModel.isRunning)
                
                Button(action: viewModel.reset) {
                    Text("Reset")
                }
            }
        }
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
    }
}