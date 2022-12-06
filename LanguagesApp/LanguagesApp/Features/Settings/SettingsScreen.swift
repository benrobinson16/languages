import SwiftUI

struct SettingsScreen: View {
    @ObservedObject private var nav = Navigator.shared
    @State private var notificationsEnabled = true
    @State private var notificationsOn = false
    @State private var reminderTime = Date()
    
    var body: some View {
        Form {
            Section(header: Text("Notifications")) {
                Toggle("Reminder Notifications", isOn: $notificationsOn)
                if notificationsOn {
                    DatePicker("Daily Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                }
            }
            .disabled(!notificationsEnabled)
            
            Section(header: Text("Account")) {
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
