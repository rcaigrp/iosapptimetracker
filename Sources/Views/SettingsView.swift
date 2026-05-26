import SwiftUI

class SettingsViewModel: ObservableObject {
    @Published var jiraBaseUrl = ""
    @Published var jiraApiToken = ""
    @Published var isSaving = false
    @Published var errorMessage = ""
    
    func saveCredentials() {
        guard !jiraBaseUrl.isEmpty && !jiraApiToken.isEmpty else {
            errorMessage = "Both fields are required"
            return
        }
        
        isSaving = true
        errorMessage = ""
        
        // Simulate Keychain save operation
        Task {
            do {
                try await KeychainService.save(
                    key: "jira_base_url",
                    data: jiraBaseUrl)
                try await KeychainService.save(
                    key: "jira_api_token",
                    data: jiraApiToken)
                
                DispatchQueue.main.async {
                    self.isSaving = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to save credentials"
                    self.isSaving = false
                }
            }
        }
    }
    
    func loadCredentials() {
        Task {
            do {
                if let baseUrl = try await KeychainService.load(key: "jira_base_url") {
                    DispatchQueue.main.async {
                        self.jiraBaseUrl = baseUrl
                    }
                }
                
                if let token = try await KeychainService.load(key: "jira_api_token") {
                    DispatchQueue.main.async {
                        self.jiraApiToken = token
                    }
                }
            } catch {
                // Handle error silently or show message
            }
        }
    }
}

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Jira API Credentials")) {
                    TextField("Jira Base URL", text: $viewModel.jiraBaseUrl)
                        .autocapitalization(.none)
                        .keyboardType(.URL)
                    
                    SecureField("API Token", text: $viewModel.jiraApiToken)
                }
                
                Section {
                    Button(action: {
                        viewModel.saveCredentials()
                    }) {
                        HStack {
                            Spacer()
                            Text("Save Credentials")
                            Spacer()
                        }
                    }
                    .disabled(viewModel.jiraBaseUrl.isEmpty || viewModel.jiraApiToken.isEmpty)
                    .alert("Error", isPresented: Binding(
                        get: { !viewModel.errorMessage.isEmpty },
                        set: { if !$0 { viewModel.errorMessage = "" } }
                    )) {
                        Button("OK") {}
                    } message: {
                        Text(viewModel.errorMessage)
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                viewModel.loadCredentials()
            }
        }
    }
}

#Preview {
    SettingsView()
}