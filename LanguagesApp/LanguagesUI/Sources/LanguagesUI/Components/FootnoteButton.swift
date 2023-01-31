import SwiftUI

/// App standardised footnote button.
public struct FootnoteButton: View {
    private let title: String
    private let action: () -> Void
    
    /// Memberwise initialiser.
    /// - Parameters:
    ///   - title: The text of the button (required).
    ///   - action: The action the button should perform when tapped (required).
    public init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(.appSecondary)
                .underline()
                .italic()
                .foregroundColor(.secondary)
        }
    }
}
