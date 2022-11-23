import SwiftUI

/// Use `SplashScrollView` if you want to control the content of the splash screen.
public struct SplashScrollView<T>: View where T: View {
    public let buttonText: String
    public let buttonColor: Color
    public let buttonTap: () -> Void
    public let content: () -> T
    
    public init(
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
    
    public var body: some View {
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
