/// Represents a message an interstitial learning view.
struct Message: Equatable {
    let title: String
    let body: String
    let option1: MessageOption
    let option2: MessageOption?
}

/// Represents a button in an alert.
struct MessageOption: Equatable {
    let name: String
    let action: () -> Void
    
    static func ==(_ lhs: MessageOption, _ rhs: MessageOption) -> Bool {
        return lhs.name == rhs.name
    }
}
