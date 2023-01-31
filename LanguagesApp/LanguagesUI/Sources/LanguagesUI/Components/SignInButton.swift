import SwiftUI

/// A "Sign In with Microsoft" button view.
public struct SignInButton: View {
    private let action: () -> Void
    
    /// Memberwise intiialiser.
    /// - Parameter action: The action to perform when the button is tapped.
    public init(action: @escaping () -> Void) {
        self.action = action
    }
    
    public var body: some View {
        Button (action: action) {
            Image("sign_in_light")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: UIScreen.main.bounds.width * 0.75)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
