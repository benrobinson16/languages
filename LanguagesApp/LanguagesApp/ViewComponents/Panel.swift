import SwiftUI

struct Panel<Content>: View where Content: View {
    let content: () -> Content
    
    var body: some View {
        content()
            .padding(4)
            .background(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .foregroundColor(.panelBackground)
            )
    }
}
