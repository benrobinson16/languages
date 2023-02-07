import SwiftUI
import LanguagesUI

/// Splash screen view with animations and sign in button.
struct SplashScreen: View {
    @StateObject private var controller = SplashController()
    @State private var shown = false
    @State private var hellos: [String]? = nil
    
    var body: some View {
        ZStack(alignment: .center) {
            Text("Languages")
                .font(.appTitle)
                .offset(y: -300)
            
            if let hellos = hellos {
                VStack(spacing: 24.0) {
                    Carousel(words: hellos.shuffled(), delay: 2.3, font: .appTitle2, moveLeft: true)
                    Carousel(words: hellos.shuffled(), delay: 0.0, font: .appSubheading, moveLeft: false)
                    Carousel(words: hellos.shuffled(), delay: 3.0, font: .appTitle2, moveLeft: true)
                    Carousel(words: hellos.shuffled(), delay: 5.0, font: .appSubheading, moveLeft: true)
                }
                .offset(y: -120)
            }
            
            RoundedRectangle(cornerRadius: UIScreen.main.bounds.width, style: .continuous)
                .foregroundColor(.appAccent)
                .frame(width: UIScreen.main.bounds.width * 2, height: UIScreen.main.bounds.width * 2)
                .offset(y: 500)
                .ignoresSafeArea()
                .overlay(
                    SignInButton(action: controller.signIn)
                        .offset(y: 250)
                )
        }
        .padding()
        .opacity(shown ? 1.0 : 0.0)
        .animation(.easeInOut(duration: 1.0), value: shown)
        .onAppear {
            shown = true
            if hellos == nil {
                hellos = FileController().readHellos()
            }
        }
        .onAppear(perform: controller.signInSilently)
        .onDisappear { shown = false }
    }
}
