import SwiftUI

/// Represents an Apple-like splash screen view.
public struct SplashScreenView: View {
    @Environment(\.presentationMode) var presentationMode
    
    /// The content the `SplashScreenView` should display.
    let content: SplashScreenData
    
    /// Creates a new ``SplashScreenView``
    /// - Parameter contentData: A representation of the screen data
    public init(_ contentData: SplashScreenData) {
        self.content = contentData
    }
    
    public var body: some View {
        SplashScrollView(buttonText: content.buttonText, buttonColor: content.tintColor) {
            content.onButtonTap()
        } content: {
            VStack(alignment: .center) {
                SplashTitleView(title: content.title, image: content.titleImage, mainColor: content.tintColor)
                    .padding(.top)
                    .padding(.top)
                InfoContainerView(content: content.infoContent, mainColor: content.tintColor)
            }
        }
    }
}
