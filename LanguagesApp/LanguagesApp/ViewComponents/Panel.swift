import SwiftUI

struct Panel<Content>: View where Content: View {
    let content: () -> Content
    
    var body: some View {
        content()
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .foregroundColor(.panelBackground)
                    .shadow(radius: 2.0)
            )
    }
}
