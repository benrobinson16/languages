import SwiftUI

/// Standardised app text field.
public struct AppTextField: View {
    @Binding private var text: String
    private var focusState: FocusState<Bool?>.Binding
    private let placeholder: String
    
    /// Memberwise initialiser.
    /// - Parameters:
    ///   - focusState: Whether the text field should currently be focused (i.e. keyboard open and typing).
    ///   - text: The current text.
    ///   - placeholder: The placeholder if no value is present.
    public init(focusState: FocusState<Bool?>.Binding, text: Binding<String>, placeholder: String) {
        self.placeholder = placeholder
        self.focusState = focusState
        self._text = text
    }
    
    public var body: some View {
        TextField(placeholder, text: $text)
            .focused(focusState, equals: true)
            .font(.appSubheading)
            .padding()
            .foregroundColor(Color.secondary)
            .background(Color.panelBackground)
            .cornerRadius(8)
            .shadow(color: Color(uiColor: .lightGray), radius: 3, x: 2, y: 2)
            .onSubmit {
                focusState.wrappedValue = nil
            }
            .onAppear {
                focusState.wrappedValue = true
            }
    }
}
