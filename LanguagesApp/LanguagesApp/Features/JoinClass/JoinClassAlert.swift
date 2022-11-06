import SwiftUI
import LanguagesAPI

struct JoinClassAlert: View {
    @StateObject private var controller = JoinClassController()
    let firstJoin: Bool
    
    var body: some View {
        TextField("Join code...", text: $controller.joinCode)
        if !firstJoin {
            Button("Cancel", action: controller.cancel)
        }
        Button("Join", action: controller.join)
    }
}
