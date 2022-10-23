import SwiftUI
import LanguagesAPI

struct HomeScreen: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.interactors) var interactors
    
    var body: some View {
        ScrollView {
            if let summary = appState.home.summary {
                VStack {
                    TitleGreeting(name: summary.studentName)
                    DailyCompletionPanel(percentage: summary.dailyPercentage) { interactors.nav.navigateTo(.learning) }
                    StreaksPanel(streakHistory: summary.streakHistory, streakLength: summary.streakLength)
                    TaskList(tasks: summary.tasks) { interactors.nav.navigateTo(.task($0)) }
                    FootnoteButton(title: "Settings") { interactors.nav.navigateTo(.settings) }
                }
                .padding(4)
            } else {
                ProgressView()
            }
        }
        .onAppear(perform: loadData)
    }
    
    func loadData() {
        interactors.home.loadSummary()
    }
}
