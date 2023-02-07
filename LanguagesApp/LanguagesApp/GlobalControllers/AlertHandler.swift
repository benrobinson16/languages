import Foundation

/// Global class to show alerts to the user.
class AlertHandler: ObservableObject {
    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage: String? = nil
    @Published var option1: MessageOption? = nil
    @Published var option2: MessageOption? = nil
    
    private init() { }
    public static let shared = AlertHandler()
    
    /// Shows a new alert to the user.
    /// - Parameters:
    ///   - title: The title of the alert.
    ///   - body: The textual body of the alert.
    ///   - option1: The left-most option of the alert.
    ///   - option2: The right-most option of the alert.
    func show(_ title: String, body: String? = nil, option1: MessageOption? = nil, option2: MessageOption? = nil) {
        DispatchQueue.main.async {
            self.alertTitle = title
            self.alertMessage = body
            self.option1 = option1
            self.option2 = option2
            self.showAlert = true
        }
    }
}
