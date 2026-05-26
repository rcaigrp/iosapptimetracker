import SwiftUI

class SettingsViewModel: ObservableObject {
    @Published var jiraBaseUrl = ""
    @Published var jiraApiToken = ""
    @Published var showAlert = false
    @Published var alertMessage = ""
    
    func validateInputs() -> Bool {
        guard !jiraBaseUrl.trimmed.isEmpty else {
            alertMessage = "Jira Base URL is required"
            showAlert = true
            return false
        }
        
        guard !jiraApiToken.trimmed.isEmpty else {
            alertMessage = "Jira API Token is required"
            showAlert = true
            return false
        }
        
        // Basic URL validation
        guard let url = URL(string: jiraBaseUrl), url.scheme != nil else {
            alertMessage = "Invalid Jira Base URL format"
            showAlert = true
            return false
        }
        
        return true
    }
    
    func saveCredentials() {
        if validateInputs() {
            // Save to Keychain (implementation details would go here)
            print("Saving credentials for \(jiraBaseUrl)")
        }
    }
}

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Jira API Credentials")) {
                    TextField("Jira Base URL", text: $viewModel.jiraBaseUrl)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        
                    SecureField("API Token", text: $viewModel.jiraApiToken)
                }
                
                Section {
                    Button("Save Credentials") {
                        viewModel.saveCredentials()
                    }
                    .disabled(viewModel.jiraBaseUrl.trimmed.isEmpty || viewModel.jiraApiToken.trimmed.isEmpty)
                }
            }
            .navigationTitle("Settings")
            .alert("Validation Error", isPresented: $viewModel.showAlert) {
                Button("OK") { }
            } message: {
                Text(viewModel.alertMessage)
            }
        }
    }
}

// Extension to trim whitespace
extension String {
    var trimmed: String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

#Preview {
    SettingsView()
}