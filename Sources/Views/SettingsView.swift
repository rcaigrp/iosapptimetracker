// MARK: - Settings View
import SwiftUI

struct SettingsView: View {
    @State private var jiraBaseURL = ""
    @State private var jiraAPIToken = ""
    @State private var showAlert = false
    
    @StateObject private var apiManager = JiraAPIManager()
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Jira API Configuration")) {
                    TextField("Jira Base URL", text: $jiraBaseURL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    SecureField("API Token", text: $jiraAPIToken)
                }
                
                Section {
                    Button("Save Credentials") {
                        apiManager.saveCredentials(baseURL: jiraBaseURL, apiToken: jiraAPIToken)
                        showAlert = true
                    }
                    .disabled(jiraBaseURL.isEmpty || jiraAPIToken.isEmpty)
                    
                    Button("Clear Credentials") {
                        apiManager.clearCredentials()
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Credentials Saved", isPresented: $showAlert) {
                Button("OK") {}
            }
        }
    }
}

#Preview {
    SettingsView()
}