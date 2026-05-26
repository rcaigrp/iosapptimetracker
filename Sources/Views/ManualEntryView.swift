import SwiftUI

struct ManualEntryView: View {
    @State private var projectName = ""
    @State private var notes = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Project")) {
                    TextField("Project Name", text: $projectName)
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
                
                Section {
                    Button(action: saveEntry) {
                        Text("Save Entry")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("Manual Entry")
        }
    }
    
    private func saveEntry() {
        // Implementation for saving manual entry
    }
}

struct ManualEntryView_Previews: PreviewProvider {
    static var previews: some View {
        ManualEntryView()
    }
}