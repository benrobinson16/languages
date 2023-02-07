import Foundation

extension Notification.Name {
    /// Represents an internal notification to refresh home page data.
    static var refreshData: Notification.Name {
        return .init("dev.benrobinson.languages.refreshData")
    }
}
