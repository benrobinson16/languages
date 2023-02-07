import Foundation
import UIKit
import UserNotifications

/// The iOS API uses the application delegate to communicate with the app.
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("DID RECEIVE REMOTE NOTIFICATION")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("REGISTERED FOR REMOTE NOTIFICATIONS")
        let tokenStr = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        ErrorHandler.shared.detachAsync {
            try await Notifier.shared.updateDeviceToken(tokenStr)
        }
    }
}
