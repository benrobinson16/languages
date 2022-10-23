import SwiftUI

extension Font {
    static var appTitle: Font {
        return .system(size: 40, weight: .semibold, design: .rounded)
    }
    
    static var appSecondary: Font {
        return .system(size: 14, weight: .regular, design: .rounded)
    }
    
    static var appSubheading: Font {
        return .system(size: 20, weight: .medium, design: .rounded)
    }
    
    static var appButton: Font {
        return .system(size: 20, weight: .semibold, design: .rounded)
    }
}
