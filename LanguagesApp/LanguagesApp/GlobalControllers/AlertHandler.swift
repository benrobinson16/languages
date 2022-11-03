import Foundation

class AlertHandler: ObservableObject {
    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage: String? = nil
    
    private init() { }
    public static let shared = AlertHandler()
    
    func show(_ title: String, body: String? = nil) {
        alertTitle = title
        alertMessage = body
        showAlert = true
    }
}
