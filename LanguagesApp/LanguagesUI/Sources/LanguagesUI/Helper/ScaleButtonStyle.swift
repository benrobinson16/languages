import SwiftUI

/// Describes a button that shrinks slightly when pressed.
struct ScaleButtonStyle: ButtonStyle {
    
    /// Conformance to the `ButtonStyle` protocol. Performs the button customisation.
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.85 : 1.0)
            .animation(.interactiveSpring(), value: configuration.isPressed)
    }
}
