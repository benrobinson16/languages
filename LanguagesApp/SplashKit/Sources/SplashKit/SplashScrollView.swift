import SwiftUI

/// Use `SplashScrollView` if you want to control the content of the splash screen.
struct SplashScrollView<T>: View where T: View {
    let buttonText: String
    let buttonColor: Color
    let buttonTap: () -> Void
    let content: () -> T
    
    init(
        buttonText: String,
        buttonColor: Color,
        buttonTap: @escaping () -> Void,
        content: @escaping () -> T
    ) {
        self.buttonText = buttonText
        self.buttonColor = buttonColor
        self.buttonTap = buttonTap
        self.content = content
    }
    
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
