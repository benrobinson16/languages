import SwiftUI

struct AlertWrapper<Content>: View where Content: View {
    let content: () -> Content
    
    @ObservedObject var errors = ErrorHandler.shared
    @ObservedObject var alerts = AlertHandler.shared
    
    var body: some View {
        content()
            .alert(
                "Error",
                isPresented: $errors.showAlert,
                presenting: errors.errorMessage
            ){ _ in
                Button("OK") {
                    Navigator.shared.goHome()
                }
            } message: { message in
                Text(message)
            }
            .alert(
                alerts.alertTitle,
                isPresented: $alerts.showAlert,
                presenting: alerts.alertMessage
            ) { _ in
                if let opt1 = alerts.option1 {
                    Button(opt1.name, action: opt1.action)
                    
                    if let opt2 = alerts.option2 {
                        Button(opt2.name, action: opt2.action)
                    }
                } else {
                    Button("OK") {
                        Navigator.shared.goHome()
                    }
                }
            } message: { message in
                Text(message)
            }

    }
}
