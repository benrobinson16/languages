import SwiftUI

extension Font {
    public static var appTitle: Font {
        return .system(size: 40, weight: .semibold, design: .rounded)
    }
    
    public static var appSecondary: Font {
        return .system(size: 20, weight: .regular, design: .rounded)
    }
    
    public static var appTitle2: Font {
        return .system(size: 24, weight: .semibold, design: .rounded)
    }
    
    public static var appSubheading: Font {
        return .system(size: 20, weight: .medium, design: .rounded)
    }
    
    public static var appButton: Font {
        return .system(size: 20, weight: .semibold, design: .rounded)
    }
}
