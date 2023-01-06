import Foundation

extension Date {
    public func appFormat() -> String {
        return self.formatted(date: .abbreviated, time: .omitted)
    }
}
