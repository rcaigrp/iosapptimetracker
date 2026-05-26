import SwiftUI

class SettingsViewModel: ObservableObject {
    @Published var jiraBaseUrl = ""
    @Published var jiraApiToken = ""
    @Published var showAlert = false
    @Published var alertMessage = ""
    
    func validateInputs() -> Bool {
        guard !jiraBaseUrl.isEmpty else {
            alertMessage = "Jira Base URL is required"
            showAlert = true
            return false
        }
        
        guard !jiraApiToken.isEmpty else {
            alertMessage = "Jira API Token is required"
            showAlert = true
            return false
        }
        
        // Basic URL validation
        guard let url = URL(string: jiraBaseUrl), url.scheme != nil else {
            alertMessage = "Please enter a valid Jira Base URL"
            showAlert = true
            return false
        }
        
        return true
    }
    
    func saveCredentials() {
        if validateInputs() {
            // In a real implementation, this would use Keychain services
            // For now, we'll just show a success message
            alertMessage = "Credentials saved successfully"
            showAlert = true
        }
    }
}

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Jira Configuration")) {
                    TextField("Jira Base URL", text: $viewModel.jiraBaseUrl)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    SecureField("Jira API Token", text: $viewModel.jiraApiToken)
                }
                
                Section {
                    Button("Save Credentials") {
                        viewModel.saveCredentials()
                    }
                    .disabled(viewModel.jiraBaseUrl.isEmpty || viewModel.jiraApiToken.isEmpty)
                }
            }
            .navigationTitle("Settings")
            .alert("Information", isPresented: $viewModel.showAlert) {
                Button("OK") { }
            } message: {
                Text(viewModel.alertMessage)
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}