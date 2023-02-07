import Foundation
import LanguagesAPI

/// Controller for the settings screen.
class SettingsController: ObservableObject {
    @Published var summary: SettingsSummary? = nil
    @Published var notificationsAllowed: Bool? = nil
    
    private var isLoading = false
    
    /// Gets the settings summary from the server.
    func loadSummary() {
        guard !isLoading else { return }
        guard let token = Authenticator.shared.token else { Navigator.shared.goHome(); return }
        
        ErrorHandler.shared.detachAsync { @MainActor in
            self.summary = try await LanguagesAPI.makeRequest(.settingsSummary(token: token))
        } finally: {
            self.isLoading = false
        }
    }
    
    /// Sets whether daily reminder notifications are enabled.
    /// - Parameter newValue: The new toggle value.
    func setNotificationsEnabled(newValue: Bool) {
        guard summary != nil else { return }
        guard let token = Authenticator.shared.token else { Navigator.shared.goHome(); return }
        
        summary?.dailyReminderEnabled = newValue
        
        ErrorHandler.shared.detachAsync {
            _ = try await LanguagesAPI.makeRequest(.updateNotificationSettings(
                time: self.summary!.reminderTime, enabled: self.summary!.dailyReminderEnabled, token: token
            ))
        }
    }
    
    /// Sets the time of the daily reminder notifications.
    /// - Parameter newValue: Time of the notifications (date componenet is ignored).
    func setNotificationsTime(newValue: Date) {
        guard summary != nil else { return }
        guard let token = Authenticator.shared.token else { Navigator.shared.goHome(); return }
        
        summary?.reminderTime = newValue
        
        ErrorHandler.shared.detachAsync {
            _ = try await LanguagesAPI.makeRequest(.updateNotificationSettings(
                time: self.summary!.reminderTime, enabled: self.summary!.dailyReminderEnabled, token: token
            ))
        }
    }
    
    /// Checks if notifications are currently allowed by the user.
    func checkNotificationsAllowed() {
        ErrorHandler.shared.detachAsync { @MainActor in
            self.notificationsAllowed = await Notifier.shared.checkNotificationsAllowed()
        }
    }
}
