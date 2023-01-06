import SwiftUI

public struct SignInButton: View {
    private let action: () -> Void
    
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
