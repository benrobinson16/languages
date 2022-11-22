import SwiftUI

extension Color {
    public static var appAccent: Color {
        return Color(red: 48.0 / 255.0, green: 99.0 / 255.0, blue: 142.0 / 255.0)
    }
    
    public static var appSecondaryAccent: Color {
        return Color(red: 255.0 / 255.0, green: 185.0 / 255.0, blue: 0.0 / 255.0)
    }
    
    public static var panelBackground: Color  {
        return Color(red: 245.0 / 255.0, green: 245.0 / 255.0, blue: 245.0 / 255.0)
    }
    
    public static var panelSecondary: Color  {
        return Color(red: 229.0 / 255.0, green: 229.0 / 255.0, blue: 229.0 / 255.0)
    }
    
    public static var backgroundRed: Color {
        return .red.opacity(0.3)
    }
    
    public static var backgroundGreen: Color {
        return .green.opacity(0.3)
    }
}
