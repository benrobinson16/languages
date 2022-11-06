import SwiftUI

struct SplashScreen: View {
    @StateObject private var controller = SplashController()
    @State private var shown = false
    
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
                    SignInButton(action: controller.signIn)
                        .offset(y: 250)
                )
        }
        .padding()
        .opacity(shown ? 1.0 : 0.0)
        .animation(.easeInOut(duration: 1.0), value: shown)
        .onAppear { shown = true }
        .onDisappear { shown = false }
    }
}
