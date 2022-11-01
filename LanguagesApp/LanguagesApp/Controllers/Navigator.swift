import Foundation
import SwiftUI

class Navigator: ObservableObject {
    @Published private(set) var state: NavRoute = .home
    
    private init() { }
    static let shared = Navigator()
    
    func goHome() {
        state = .home
    }
    
    func open(_ route: NavRoute) {
        state = route
    }
}
