import SwiftUI

struct SettingsScreen: View {
    @ObservedObject private var nav = Navigator.shared
    @StateObject private var controller = SettingsController()
    
    var body: some View {
        NavigationView {
            Form {
                if let summary = controller.summary, let notificationsAllowed = controller.notificationsAllowed {
                    Section {
                        Toggle(
                            "Reminder Notifications",
                            isOn: .init(get: { summary.dailyReminderEnabled }, set: controller.setNotificationsEnabled)
                        )
                        .opacity(notificationsAllowed ? 1.0 : 0.5)
                        
                        if summary.dailyReminderEnabled && notificationsAllowed {
                            DatePicker(
                                "Daily Reminder Time",
                                selection: .init(get: { summary.reminderTime }, set: controller.setNotificationsTime),
                                displayedComponents: .hourAndMinute
                            )
                        }
                    } header: {
                        Text("Notifications")
                    } footer: {
                        if !notificationsAllowed {
                            Text("Please enable notifications in the iOS Settings.")
                        }
                    }
                    .disabled(!notificationsAllowed)

                    Section {
                        LabeledContent("Name", value: summary.name)
                        LabeledContent("Email", value: summary.email)
                        Button.init("Log out", role: .destructive, action: Authenticator.shared.signOutDetached)
                    } header: {
                        Text("Account")
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
            .navigationTitle(Text("Settings"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: nav.goHome) {
                        Text("Close")
                    }
                }
            }
        }
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
