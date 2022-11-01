import SwiftUI
import LanguagesAPI

struct HomeScreen: View {
    @StateObject private var controller = HomeController()
    @ObservedObject private var nav = Navigator.shared
    
    var body: some View {
        ScrollView {
            if let summary = controller.summary {
                VStack(alignment: .leading, spacing: 16) {
                    Spacer(minLength: 50)
                    TitleGreeting(name: summary.studentName)
                    Spacer(minLength: 50)
                    DailyCompletionPanel(percentage: summary.dailyPercentage) { nav.open(.learning) }
                    StreaksPanel(streakHistory: summary.streakHistory, streakLength: summary.streakLength)
                    Spacer(minLength: 30)
                    TaskList(tasks: summary.tasks) { nav.open(.task($0)) }
                    Spacer(minLength: 30)
                    HStack {
                        Spacer()
                        FootnoteButton(title: "Settings") { nav.open(.settings) }
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
        .onAppear {
            controller.loadSummary()
        }
    }
}
