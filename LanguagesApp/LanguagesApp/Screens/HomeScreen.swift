import SwiftUI
import LanguagesAPI

struct HomeScreen: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.interactors) var interactors
    
    var body: some View {
        ScrollView {
            if let summary = appState.home.summary {
                VStack(alignment: .leading, spacing: 16) {
                    Spacer(minLength: 50)
                    TitleGreeting(name: summary.studentName)
                    Spacer(minLength: 50)
                    DailyCompletionPanel(percentage: summary.dailyPercentage) { interactors.nav.navigateTo(.learning) }
                    StreaksPanel(streakHistory: summary.streakHistory, streakLength: summary.streakLength)
                    Spacer(minLength: 30)
                    TaskList(tasks: summary.tasks) { interactors.nav.navigateTo(.task($0)) }
                    Spacer(minLength: 30)
                    HStack {
                        Spacer()
                        FootnoteButton(title: "Settings") { interactors.nav.navigateTo(.settings) }
                        Spacer()
                    }
                }
                .padding(16)
            } else {
                VStack {
                    Spacer(minLength: 400)
                    ProgressView()
                }
            }
        }
        .onAppear(perform: loadData)
    }
    
    func loadData() {
        interactors.home.loadSummary()
    }
}
