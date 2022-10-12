import SwiftUI

struct LearningScreen: View {
    @Environment(\.interactors) var interactors
    
    var body: some View {
        Button("Close") { interactors.nav.goHome() }
    }
}
