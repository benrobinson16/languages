import Foundation
import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("DID RECEIVE REMOTE NOTIFICATION")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenStr = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        ErrorHandler.shared.detachAsync {
            try await Notifier.updateDeviceToken(tokenStr)
        }
    }
}
