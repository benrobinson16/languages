import SwiftUI

struct AppButton: View {
    var enabled: Bool = true
    var color: Color = .appAccent
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                Text(title)
                    .font(.appButton)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .foregroundColor(color)
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(!enabled)
        .opacity(enabled ? 1.0 : 0.8)
    }
}
