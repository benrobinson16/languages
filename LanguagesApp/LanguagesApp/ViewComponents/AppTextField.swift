import SwiftUI

struct AppTextField: View {
    @FocusState var focusState: Bool?
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        TextField(placeholder, text: $text)
            .focused($focusState, equals: true)
            .font(.appSubheading)
            .padding()
            .foregroundColor(Color.secondary)
            .background(Color.panelBackground)
            .cornerRadius(8)
            .shadow(color: Color(uiColor: .lightGray), radius: 3, x: 2, y: 2)
            .onSubmit {
                focusState = nil
            }
            .onAppear {
                focusState = true
            }
    }
}
