import SwiftUI

/// Represents the data required to present a `SplashScreenView`.
public struct SplashScreenData {
    
    /// The title of the `SplashScreenView` represented as two lines of text.
    public let title: (line1: String, line2: String)
    
    /// An image to display beneath the title. Erase to `AnyView`.
    public let titleImage: AnyView?
    
    /// An array of all the `InfoDetailData` to display as rows in the `ScrollView`.
    public let infoContent: [InfoDetailData]
    
    /// The text of the button. E.g. "continue", "next" or "start exploring".
    public let buttonText: String
    
    /// A callback for when the button is tapped.
    public let onButtonTap: () -> Void
    
    /// The tint color to apply to the title line 2 and the info detail row images.
    public let tintColor: Color
    
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

/// Represents the data required to display an info detail row.
public struct InfoDetailData: Identifiable {
    
    /// The image (generally a symbol) to display.
    public let image: Image
    
    /// The title of the row (e.g. "New feature")
    public let title: String
    
    /// The body of the row (e.g. "This is a new feature to ThisApp and we think you'll love it!")
    public let body: String
    
    /// Conformance to `Identifiable`.
    public let id = UUID()
    
    public init(image: Image,
                title: String,
                body: String) {
        self.image = image
        self.title = title
        self.body = body
    }
}
