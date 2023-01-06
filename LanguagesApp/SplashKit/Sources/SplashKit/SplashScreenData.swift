import SwiftUI

/// Represents the data required to present a `SplashScreenView`.
public struct SplashScreenData {
    
    /// The title of the `SplashScreenView` represented as two lines of text.
    let title: (line1: String, line2: String)
    
    /// An image to display beneath the title. Erase to `AnyView`.
    let titleImage: AnyView?
    
    /// An array of all the `InfoDetailData` to display as rows in the `ScrollView`.
    let infoContent: [InfoDetailData]
    
    /// The text of the button. E.g. "continue", "next" or "start exploring".
    let buttonText: String
    
    /// A callback for when the button is tapped.
    let onButtonTap: () -> Void
    
    /// The tint color to apply to the title line 2 and the info detail row images.
    let tintColor: Color
    
    public init(title: (line1: String, line2: String),
                titleImage: AnyView?,
                infoContent: [InfoDetailData],
                buttonText: String,
                onButtonTap: @escaping () -> Void,
                tintColor: Color) {
        self.title = title
        self.titleImage = titleImage
        self.infoContent = infoContent
        self.buttonText = buttonText
        self.onButtonTap = onButtonTap
        self.tintColor = tintColor
    }
    
}
