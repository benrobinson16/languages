import SwiftUI

struct AppButton: View {
    let title: String
    let action: () -> Void
    
    @State private var touchDown = false
    
    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .foregroundColor(.appAccent)
                .overlay(
                    Text(title)
                        .font(.appButton)
                        .foregroundColor(.white)
                        .padding(4)
                )
                .scaleEffect(touchDown ? 0.75 : 1.0)
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in touchDown = true }
                .onEnded { _ in touchDown = false }
        )
    }
}
