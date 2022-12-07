import Foundation
import LanguagesAPI

class SettingsController: ObservableObject {
    @Published var summary: SettingsSummary? = nil
    @Published var notificationsAllowed: Bool? = nil
    
    private var isLoading = false
    
    func loadSummary() {
        guard !isLoading else { return }
        guard let token = Authenticator.shared.token else { Navigator.shared.goHome(); return }
        
        ErrorHandler.shared.detachAsync { @MainActor in
            self.summary = try await LanguagesAPI.makeRequest(.settingsSummary(token: token))
        } finally: {
            self.isLoading = false
        }
    }
    
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
    
    func checkNotificationsAllowed() {
        ErrorHandler.shared.detachAsync { @MainActor in
            self.notificationsAllowed = await Notifier.shared.checkNotificationsAllowed()
        }
    }
}
