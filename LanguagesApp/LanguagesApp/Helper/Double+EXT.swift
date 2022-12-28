import Foundation

extension Double {
    func formatPercentage() -> String {
        guard self <= 1.0 else { return "100%" }
        guard self >= 0.0 else { return "0%" }
        
        return "\(Int(floor(self * 100.0)))%"
    }
}
