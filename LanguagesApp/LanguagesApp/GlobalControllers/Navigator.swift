import Foundation
import SwiftUI

/// Global class to manage the navigation state of the app.
class Navigator: ObservableObject {
    @Published private(set) var state: NavRoute = .home
    
    private init() { }
    
    /// Use a singleton so everywhere can access and modify navigation state.
    static let shared = Navigator()
    
    /// Returns the navigation state to home.
    func goHome() {
        Task { @MainActor in
            state = .home
        }
    }
    
    /// Navigates to a new page.
    /// - Parameter route: The page to open.
    func open(_ route: NavRoute) {
        Task { @MainActor in
            state = route
        }
    }
}
