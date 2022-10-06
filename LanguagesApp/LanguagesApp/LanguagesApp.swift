import Foundation
import SwiftUI
import MSAL

@main
struct LanguagesApp: App {
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var msal = MSAuthManager()!
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    guard let vc = UIApplication.shared.topViewController else { return }
                    msal.connectToViewController(vc: vc)
                    msal.detachedAcquireToken()
                }
                .onChange(of: scenePhase) { scenePhase in
                    if scenePhase == .active {
                        msal.detachedAcquireToken()
                    }
                }
                .onOpenURL { url in
                    msal.openUrl(url: url)
                }
                .environmentObject(msal)
        }
    }
}
