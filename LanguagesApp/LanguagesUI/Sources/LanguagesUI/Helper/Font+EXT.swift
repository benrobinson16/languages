import SwiftUI

extension Font {
    
    /// A font for large titles within the app.
    public static var appTitle: Font {
        return .system(size: 40, weight: .semibold, design: .rounded)
    }
    
    /// A font for secondary titles in the app that are not as important as the main ones.
    public static var appTitle2: Font {
        return .system(size: 24, weight: .semibold, design: .rounded)
    }
    
    /// A font for text displayed immediately beneath/next to a title.
    public static var appSubheading: Font {
        return .system(size: 20, weight: .medium, design: .rounded)
    }
    
    /// A font for secondary, less important text. Often given the color `Color.secondary`.
    public static var appSecondary: Font {
        return .system(size: 20, weight: .regular, design: .rounded)
    }
    
    /// A font for the standard app button component.
    public static var appButton: Font {
        return .system(size: 20, weight: .semibold, design: .rounded)
    }
}
