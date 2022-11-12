import Foundation
import SwiftUI
import MSAL

@main
struct LanguagesApp: App {
    @UIApplicationDelegateAdaptor private var delegate = AppDelegate()
    
    var body: some Scene {
        WindowGroup {
            AlertWrapper {
                RootNav()
            }
        }
    }
}
