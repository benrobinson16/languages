import SwiftUI

struct TaskScreen: View {
    @Environment(\.interactors) var interactors
    
    var body: some View {
        Button("Close") { interactors.nav.goHome() }
    }
}
