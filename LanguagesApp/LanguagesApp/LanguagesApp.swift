import Foundation
import SwiftUI
import MSAL

@main
struct LanguagesApp: App {
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            AlertWrapper {
                RootNav()
            }
        }
    }
}
