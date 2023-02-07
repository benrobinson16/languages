import Foundation
import UIKit

extension UIApplication {
    /// The top view controller on the current stack.
    var topViewController: UIViewController? {
        return UIApplication
            .shared
            .connectedScenes
            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
            .filter { $0.isKeyWindow }
            .first?
            .rootViewController?
            .top()
    }
}

extension UIViewController {
    /// Gets the top view controller from a tab bar, nav bar or single controller.
    /// - Returns: The top view controller from a given view controller.
    func top() -> UIViewController {
        if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController ?? tabBarController
        } else if let navigationController = self as? UINavigationController {
            return navigationController.visibleViewController?.top() ?? navigationController
        } else {
            return presentedViewController?.top() ?? self
        }
    }
}
