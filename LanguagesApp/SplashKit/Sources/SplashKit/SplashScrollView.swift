import SwiftUI

/// Provides a scroll view for the info container views, so that they can all display regardless of screen size.
struct SplashScrollView<T>: View where T: View {
    let buttonText: String
    let buttonColor: Color
    let buttonTap: () -> Void
    let content: () -> T
    
    var body: some View {
        ZStack {
            ScrollView {
                content()
                
                Spacer(minLength: 80)
            }
            
            VStack {
                Spacer()
                
                SplashButton(buttonText: buttonText, buttonColor: buttonColor, buttonTap: buttonTap)
                    .padding(.top)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(.systemBackground),
                                                        Color(.systemBackground),
                                                        Color(.systemBackground),
                                                        Color(.systemBackground).opacity(0.0)]),
                            startPoint: .center,
                            endPoint: .top)
                            .edgesIgnoringSafeArea(.bottom)
                    )
            }
        }
    }
}
