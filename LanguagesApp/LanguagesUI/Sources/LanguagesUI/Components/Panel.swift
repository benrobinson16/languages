import SwiftUI

/// App standardised panel component (i.e. rounded rectangle background). Generic over `Content` - the type of the contained view.
public struct Panel<Content>: View where Content: View {
    private let color: Color
    private let content: () -> Content
    
    /// Memberwise initialiser.
    /// - Parameters:
    ///   - color: The background color. `Color.panelBackground` by default.
    ///   - content: A view-builder function returning the content of the panel.
    public init(color: Color = .panelBackground, content: @escaping () -> Content) {
        self.color = color
        self.content = content
    }
    
    public var body: some View {
        content()
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .foregroundColor(color)
            )
    }
}
