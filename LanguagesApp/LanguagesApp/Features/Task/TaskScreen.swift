import SwiftUI

struct TaskScreen: View {
    @ObservedObject private var nav = Navigator.shared
    
    var body: some View {
        Button("Close") { nav.goHome() }
    }
}
