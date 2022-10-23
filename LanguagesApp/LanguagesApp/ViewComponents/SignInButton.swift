import SwiftUI

struct SignInButton: View {
    let action: () -> Void
    
    @State private var touchDown = false
    
    var body: some View {
        Button (action: action) {
            Image("sign_in_light")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: UIScreen.main.bounds.width * 0.75)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.85 : 1.0)
            .animation(.interactiveSpring(), value: configuration.isPressed)
    }
}
