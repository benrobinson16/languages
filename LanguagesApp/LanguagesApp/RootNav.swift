import SwiftUI
import DataStructures

struct RootNav: View {
    @ObservedObject private var nav = Navigator.shared
    @ObservedObject private var auth = Authenticator.shared
    
    var body: some View {
        Group {
            if auth.token == nil {
                SplashScreen()
            } else {
                HomeScreen()
                    .fullScreenCover(isPresented: .init(
                        get: { nav.state == .learning },
                        set: { _ in nav.goHome() }
                    )) {
                        LearningScreenWrapper()
                    }
                    .sheet(isPresented: .init(
                        get: { nav.state.isTask() },
                        set: { _ in nav.goHome() }
                    )) {
                        TaskScreen()
                    }
                    .sheet(isPresented: .init(
                        get: { nav.state == .settings },
                        set: { _ in nav.goHome() }
                    )) {
                        SettingsScreen()
                    }
                    .sheet(isPresented: .init(
                        get: { nav.state == .onboarding },
                        set: { _ in nav.goHome() }
                    )) {
                        Text("Onboarding")
                    }
                    .alert("Join Class", isPresented: .init(
                        get: { nav.state == .joinClass },
                        set: { _ in nav.goHome() }
                    )) {
                        JoinClassAlert() // FIXME: Define view
                    }
            }
        }
        .onOpenURL { url in
            auth.openUrl(url: url)
        }
        .onAppear {
            guard let vc = UIApplication.shared.topViewController else { return }
            auth.connectToViewController(vc: vc)
            auth.signInSilentlyDetached()
        }
    }
}
