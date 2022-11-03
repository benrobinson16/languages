import SwiftUI

struct AlertWrapper<Content>: View where Content: View {
    let content: () -> Content
    
    @ObservedObject var errors = ErrorHandler.shared
    
    var body: some View {
        content()
            .alert(
                "Error",
                isPresented: $errors.showAlert,
                presenting: errors.errorMessage,
                actions: { _ in
                    Button("OK") {
                        Navigator.shared.goHome()
                    }
                }, message: { message in
                    Text(message)
                }
            )
    }
}
