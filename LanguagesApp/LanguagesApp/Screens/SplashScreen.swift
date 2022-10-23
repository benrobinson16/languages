import SwiftUI

struct SplashScreen: View {
    @Environment(\.interactors) var interactors
    
    var body: some View {
        ZStack(alignment: .center) {
            Text("Languages")
                .font(.appTitle)
                .offset(y: -300)
            
            RoundedRectangle(cornerRadius: UIScreen.main.bounds.width, style: .continuous)
                .foregroundColor(.appAccent)
                .frame(width: UIScreen.main.bounds.width * 2, height: UIScreen.main.bounds.width * 2)
                .offset(y: 500)
                .ignoresSafeArea()
                .overlay(
                    SignInButton(action: signInAction)
                        .offset(y: 250)
                )
        }
        .padding()
    }
    
    func signInAction() {
        guard let vc = UIApplication.shared.topViewController else { return }
        interactors.auth.connectToViewController(vc: vc)
        interactors.auth.signIn()
    }
}
