import Foundation

extension Date {
    
    /// App standardised date format.
    /// - Returns: The formatted date, e.g. "17 Oct 2023".
    public func appFormat() -> String {
        return self.formatted(date: .abbreviated, time: .omitted)
    }
}
