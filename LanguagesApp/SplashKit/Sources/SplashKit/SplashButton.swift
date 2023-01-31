import SwiftUI

/// View component for the button at the bottom of the onboarding screen.
struct SplashButton: View {
    let buttonText: String
    let buttonColor: Color
    let buttonTap: () -> Void
    
    var body: some View {
        Button {
            buttonTap()
        } label: {
            Text(buttonText)
                .foregroundColor(.white)
                .font(.headline)
                .padding()
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(buttonColor))
                .padding(.bottom)
        }
        .padding(.horizontal)
        .padding(.top)
    }
}
