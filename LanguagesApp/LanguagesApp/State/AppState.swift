import Foundation
import LanguagesAPI
import SwiftUI

class AppState: ObservableObject {
    @Published var auth = AuthState()
    @Published var page: NavRoute = .home
    @Published var home = HomeState()
    @Published var error: String? = nil
}
