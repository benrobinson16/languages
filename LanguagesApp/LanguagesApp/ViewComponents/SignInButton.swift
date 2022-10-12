import SwiftUI

struct SignInButton: View {
    @Environment(\.interactors) var interactors
    
    var body: some View {
        Image("sign_in_light")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: UIScreen.main.bounds.width * 0.8)
            .onTapGesture {
                guard let vc = UIApplication.shared.topViewController else { return }
                interactors.auth.connectToViewController(vc: vc)
                interactors.auth.signIn()
            }
    }
}
