import SwiftUI

public struct FootnoteButton: View {
    private let title: String
    private let action: () -> Void
    
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
