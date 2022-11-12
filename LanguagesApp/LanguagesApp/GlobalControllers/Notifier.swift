import Foundation
import UIKit
import UserNotifications
import LanguagesAPI

class Notifier {
    private var lastDeviceToken: String? = nil
    
    private init() { }
    static let shared = Notifier()
    
    func registerForPushNotifications() {
        UIApplication.shared.registerForRemoteNotifications()
    }
    
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
    
    private func checkPermissionStatus() async -> UNAuthorizationStatus {
        return await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                continuation.resume(with: .success(settings.authorizationStatus))
            }
        }
    }
    
    func updateDeviceToken(_ deviceToken: String) async throws {
        // Avoid updating to an identical token
        guard deviceToken != lastDeviceToken else { return }
        lastDeviceToken = deviceToken
        
        guard let token = Authenticator.shared.token else { throw AppError.notAuthenticated }
        _ = try await LanguagesAPI.makeRequest(.registerDevice(device: deviceToken, token: token))
    }
    
    func removeDeviceToken() async throws {
        guard let token = Authenticator.shared.token else { throw AppError.notAuthenticated }
        _ = try await LanguagesAPI.makeRequest(.removeRegisteredDevice(token: token))
        lastDeviceToken = nil
    }
}
