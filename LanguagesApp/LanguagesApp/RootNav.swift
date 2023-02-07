import SwiftUI
import DataStructures

/// The root navigation controller, managing what screen is currently shown.
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
                            .interactiveDismissDisabled()
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
                        get: { nav.state == .onboarding || nav.state == .firstJoinClass },
                        set: { _ in nav.goHome() }
                    )) {
                        OnboardingScreen()
                            .interactiveDismissDisabled()
                            .alert("Join Class", isPresented: .init(
                                get: { nav.state == .firstJoinClass },
                                set: { _ in }
                            )) {
                                JoinClassAlert(firstJoin: true)
                            } message: {
                                Text("To join a class, ask your teacher for the class join code.")
                            }
                    }
                    .alert("Join Class", isPresented: .init(
                        get: { nav.state == .joinClass },
                        set: { _ in }
                    )) {
                        JoinClassAlert(firstJoin: false)
                    } message: {
                        Text("To join a class, ask your teacher for the class join code.")
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
