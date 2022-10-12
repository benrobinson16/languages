import Foundation
import UIKit

extension UIApplication {
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
