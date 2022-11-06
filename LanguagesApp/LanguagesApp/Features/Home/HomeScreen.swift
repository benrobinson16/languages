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
                        .padding(.bottom, 50)
                    DailyCompletionPanel(percentage: summary.dailyPercentage) { nav.open(.learning) }
                    StreaksPanel(streakHistory: summary.streakHistory, streakLength: summary.streakLength)
                        .padding(.bottom, 30)
                    TaskList(tasks: summary.tasks) { nav.open(.task($0)) }
                        .padding(.bottom, 30)
                    ClassList(classes: summary.enrollments, joinClass: controller.joinClass, deleteEnrollment: controller.leaveClass)
                        .padding(.bottom, 30)
                    HStack {
                        Spacer()
                        FootnoteButton(title: "Settings") { nav.open(.settings) }
                        FootnoteButton(title: "Join Class") { nav.open(.joinClass) }
                        Spacer()
                    }
                }
                .padding()
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
