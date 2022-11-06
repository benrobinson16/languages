import Foundation

class AlertHandler: ObservableObject {
    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage: String? = nil
    @Published var option1: MessageOption? = nil
    @Published var option2: MessageOption? = nil
    
    private init() { }
    public static let shared = AlertHandler()
    
    func show(_ title: String, body: String? = nil, option1: MessageOption? = nil, option2: MessageOption? = nil) {
        self.alertTitle = title
        self.alertMessage = body
        self.option1 = option1
        self.option2 = option2
        self.showAlert = true
    }
}
