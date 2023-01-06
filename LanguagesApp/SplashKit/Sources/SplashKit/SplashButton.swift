import SwiftUI

struct SplashButton: View {
    let buttonText: String
    let buttonColor: Color
    let buttonTap: () -> Void
    
    init(buttonText: String, buttonColor: Color, buttonTap: @escaping () -> Void) {
        self.buttonText = buttonText
        self.buttonColor = buttonColor
        self.buttonTap = buttonTap
    }
    
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
