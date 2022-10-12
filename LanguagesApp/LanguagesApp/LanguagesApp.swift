import Foundation
import SwiftUI
import MSAL

@main
struct LanguagesApp: App {
    @Environment(\.scenePhase) var scenePhase
    @StateObject var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            RootNav()
                .environmentObject(appState)
                .environment(\.interactors, Interactors(appState: appState))
//                .onChange(of: scenePhase) { scenePhase in
//                    if scenePhase == .active {
//                        msal.detachedAcquireToken()
//                    }
//                }
        }
    }
}
