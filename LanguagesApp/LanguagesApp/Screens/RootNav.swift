import SwiftUI
import DataStructures

struct RootNav: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.interactors) var interactors
    
    var body: some View {
        Group {
            if appState.auth.token == nil {
                SplashScreen()
            } else {
                HomeScreen()
                    .fullScreenCover(isPresented: .init(
                        get: { appState.page == .learning },
                        set: { _ in interactors.nav.goHome() }
                    )) {
                        LearningScreen()
                    }
                    .sheet(isPresented: .init(
                        get: { appState.page.isTask() },
                        set: { _ in interactors.nav.goHome() }
                    )) {
                        TaskScreen()
                    }
                    .sheet(isPresented: .init(
                        get: { appState.page == .settings },
                        set: { _ in interactors.nav.goHome() }
                    )) {
                        SettingsScreen()
                    }
                    .sheet(isPresented: .init(
                        get: { appState.page == .onboarding },
                        set: { _ in interactors.nav.goHome() }
                    )) {
                        Text("Onboarding")
                    }
            }
        }
        .onOpenURL { url in
            interactors.auth.openUrl(url: url)
        }
        .onAppear {
            guard let vc = UIApplication.shared.topViewController else { return }
            interactors.auth.connectToViewController(vc: vc)
            interactors.auth.signInSilently()
        }
    }
}

