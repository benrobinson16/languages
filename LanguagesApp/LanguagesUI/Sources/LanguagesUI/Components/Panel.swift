import SwiftUI

public struct Panel<Content>: View where Content: View {
    private let color: Color
    private let content: () -> Content
    
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
