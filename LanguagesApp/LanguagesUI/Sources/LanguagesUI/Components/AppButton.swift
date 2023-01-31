import SwiftUI

/// Provides the default main button styling for the app.
public struct AppButton: View {
    private let enabled: Bool
    private let color: Color
    private let title: String
    private let action: () -> Void
    
    /// Memberwise initialiser.
    /// - Parameters:
    ///   - enabled: Whether the button is tappable. Button will be greyed out if false.
    ///   - color: The accent colour. ``Color.appAccent`` by default.
    ///   - title: The title on the button (required).
    ///   - action: The action for the button to complete when tapped (required).
    public init(enabled: Bool = true, color: Color = .appAccent, title: String, action: @escaping () -> Void) {
        self.enabled = enabled
        self.color = color
        self.title = title
        self.action = action
    }
    
    public var body: some View {
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
