import Foundation
import SwiftUI

class Navigator: ObservableObject {
    @Published private(set) var state: NavRoute = .home
    
    private init() { }
    static let shared = Navigator()
    
    func goHome() {
        Task { @MainActor in
            state = .home
        }
    }
    
    func open(_ route: NavRoute) {
        Task { @MainActor in
            state = route
        }
    }
}
