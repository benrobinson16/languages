import Foundation
import SwiftUI

/// The root application.
@main
struct LanguagesApp: App {
    @UIApplicationDelegateAdaptor private var delegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            AlertWrapper {
                RootNav()
            }
        }
    }
}
