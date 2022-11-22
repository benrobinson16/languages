import SwiftUI

struct Panel<Content>: View where Content: View {
    var color: Color = .panelBackground
    let content: () -> Content
    
    var body: some View {
        content()
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .foregroundColor(color)
            )
    }
}
