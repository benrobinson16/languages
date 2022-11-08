import Foundation

extension Date {
    func appFormat() -> String {
        return self.formatted(date: .abbreviated, time: .omitted)
    }
}
