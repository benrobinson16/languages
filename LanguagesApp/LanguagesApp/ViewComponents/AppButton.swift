import SwiftUI

struct AppButton: View {
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
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .foregroundColor(.appAccent)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
