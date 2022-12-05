import SwiftUI

struct SettingsScreen: View {
    @ObservedObject private var nav = Navigator.shared
    
    
    
    var body: some View {
        Form {
            Section {
                Button.init("Log out", role: .destructive, action: Authenticator.shared.signOutDetached)
            }
            
            Section {
                Text("Languages v\(version) (\(build))")
                Text("Created by Ben Robinson")
            }
        }
        .formStyle(.automatic)
    }
    
    var version: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "ERROR"
    }
    
    var build: String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "ERROR"
    }
}
