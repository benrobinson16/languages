import SwiftUI

struct SettingsScreen: View {
    @ObservedObject private var nav = Navigator.shared
    @StateObject private var controller = SettingsController()
    
    var body: some View {
        Form {
            SheetHeading(title: "Settings", dismiss: nav.goHome)
            
            if let summary = controller.summary, let notificationsAllowed = controller.notificationsAllowed {
                Section(header: Text("Notifications")) {
                    Toggle(
                        "Reminder Notifications",
                        isOn: .init(get: { summary.dailyReminderEnabled }, set: controller.setNotificationsEnabled)
                    )
                    if summary.dailyReminderEnabled {
                        DatePicker(
                            "Daily Reminder Time",
                            selection: .init(get: { summary.reminderTime }, set: controller.setNotificationsTime),
                            displayedComponents: .hourAndMinute
                        )
                    }
                }
                .disabled(!notificationsAllowed)
                
                Section(header: Text("Account")) {
                    LabeledContent("Name", value: summary.firstName + " " + summary.surname)
                    LabeledContent("Email", value: summary.email)
                    Button.init("Log out", role: .destructive, action: Authenticator.shared.signOutDetached)
                }
            } else {
                ProgressView()
            }
            
            Section {
                Text("Languages v\(version) (\(build))")
                Text("Created by Ben Robinson")
            }
        }
        .formStyle(.automatic)
        .onAppear(perform: controller.loadSummary)
        .onAppear(perform: controller.checkNotificationsAllowed)
    }
    
    var version: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "ERROR"
    }
    
    var build: String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "ERROR"
    }
}
