import SwiftUI

struct Panel<Content>: View where Content: View {
    let content: () -> Content
    
    var body: some View {
        content()
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .foregroundColor(.panelBackground)
            )
    }
}
