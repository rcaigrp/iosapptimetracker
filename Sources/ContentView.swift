import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Time Tracker Dashboard")
                .font(.largeTitle)
                .padding()
            
            // Timer display
            Text("00:00:00")
                .font(.title2)
                .padding()
            
            // Controls
            HStack {
                Button("Start") {
                    // Start timer logic
                }
                .padding()
                
                Button("Stop") {
                    // Stop timer logic
                }
                .padding()
                
                Button("Reset") {
                    // Reset timer logic
                }
                .padding()
            }
            
            Spacer()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}