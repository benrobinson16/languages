import SwiftUI
import LanguagesAPI

struct HomeScreen: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.interactors) var interactors
    
    var body: some View {
        VStack {
            Button("Learning") { interactors.nav.navigateTo(.home) }
            Button("Task") { interactors.nav.navigateTo(.task(0)) }
            Button("Settings") { interactors.nav.navigateTo(.settings) }
        }
        .onAppear(perform: loadData)
    }
    
    func loadData() {
        interactors.home.loadSummary()
    }
}
