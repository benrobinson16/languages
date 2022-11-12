import Foundation
import UIKit
import UserNotifications
import LanguagesAPI

// Can be a struct because it does not need to store state.
struct Notifier {
    private init() { }
    
    static func askForPermissionIfNeeded() async {
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
    
    private static func checkPermissionStatus() async -> UNAuthorizationStatus {
        return await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                continuation.resume(with: .success(settings.authorizationStatus))
            }
        }
    }
    
    static func updateDeviceToken(_ deviceToken: String) async throws {
        guard let token = Authenticator.shared.token else { throw AppError.notAuthenticated }
        _ = try await LanguagesAPI.makeRequest(.registerDevice(device: deviceToken, token: token))
    }
    
    static func removeDeviceToken() async throws {
        guard let token = Authenticator.shared.token else { throw AppError.notAuthenticated }
        _ = try await LanguagesAPI.makeRequest(.removeRegisteredDevice(token: token))
    }
}
