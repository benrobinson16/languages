import SwiftUI

struct SettingsScreen: View {
    @ObservedObject private var nav = Navigator.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                SheetHeading(title: "Settings") { nav.goHome() }
                
                Form {
                    
                }
                .formStyle(.automatic)
            }
        }
    }
}
