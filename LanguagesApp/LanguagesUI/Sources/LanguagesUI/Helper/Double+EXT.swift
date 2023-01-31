import Foundation

extension Double {
    
    /// Formats a double in the range [0, 1] to be a user-displayable string.
    /// - Returns: The formatted percentage.
    public func formatPercentage() -> String {
        guard self <= 1.0 else { return "100%" }
        guard self >= 0.0 else { return "0%" }
        
        return "\(Int(floor(self * 100.0)))%"
    }
}
