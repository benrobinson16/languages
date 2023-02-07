import Foundation
import UIKit
import UserNotifications
import LanguagesAPI

/// Global controller to manage permissions for notifications.
class Notifier: NSObject, UNUserNotificationCenterDelegate {
    private var lastDeviceToken: String? = nil
    
    private override init() { }
    static let shared = Notifier()
    
    /// Registers the device for push notifications with the server.
    func registerForPushNotifications() {
        UIApplication.shared.registerForRemoteNotifications()
        UNUserNotificationCenter.current().delegate = self
    }
    
    /// Asks the user for permission to deliver notifications.
    func askForPermissionIfNeeded() async {
        let status = await checkPermissionStatus()
        
        if status == .notDetermined {
            await ErrorHandler.shared.wrapAsync {
                let success = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
                
                if success {
                    await UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    /// Checks if the user has authorized the app to deliver notifications.
    /// - Returns: Whether notifications are authorized.
    func checkNotificationsAllowed() async -> Bool {
        return await checkPermissionStatus() == .authorized
    }
    
    /// Gets the specific auth status for notifications.
    /// - Returns: The current auth status.
    func checkPermissionStatus() async -> UNAuthorizationStatus {
        return await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                continuation.resume(with: .success(settings.authorizationStatus))
            }
        }
    }
    
    /// Updates the device token with the server to ensure push notifications are delivered.
    /// - Parameter deviceToken: The token to address this device.
    func updateDeviceToken(_ deviceToken: String) async throws {
        // Avoid updating to an identical token
        guard deviceToken != lastDeviceToken else { return }
        lastDeviceToken = deviceToken
        
        guard let token = Authenticator.shared.token else { throw AppError.notAuthenticated }
        _ = try await LanguagesAPI.makeRequest(.registerDevice(device: deviceToken, token: token))
    }
    
    /// Remove the token from this device on the server.
    func removeDeviceToken() async throws {
        guard let token = Authenticator.shared.token else { throw AppError.notAuthenticated }
        _ = try await LanguagesAPI.makeRequest(.removeRegisteredDevice(token: token))
        lastDeviceToken = nil
    }
    
    /// Override this method of ``UNUserNotificationCenterDelegate`` to allow notification delivery in the foreground.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions
    ) -> Void) {
        // Still present the alert when in the foreground
        completionHandler([.banner, .sound])
    }
}
