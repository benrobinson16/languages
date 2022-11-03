import SwiftUI
import LanguagesAPI



struct JoinClassAlert: View {
    @StateObject private var controller = JoinClassController()
    
    var body: some View {
        TextField("Join code...", text: $controller.joinCode)
        Button("Cancel", action: controller.cancel)
        Button("Join", action: controller.join)
    }
}
