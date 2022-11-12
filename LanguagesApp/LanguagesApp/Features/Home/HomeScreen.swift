import SwiftUI
import LanguagesAPI

struct HomeScreen: View {
    @StateObject private var controller = HomeController()
    @ObservedObject private var nav = Navigator.shared
    @State private var opacity = 0.0
    
    var body: some View {
        ScrollView {
            if let summary = controller.summary {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 8) {
                        Spacer()
                        Button(action: controller.signOut) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.appSubheading)
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.bottom, 40)
                    
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
                        FootnoteButton(title: "Refresh") { controller.loadSummary() }
                        Spacer()
                    }
                }
                .padding()
                .opacity(opacity)
                .animation(.default, value: opacity)
            } else {
                VStack {
                    Spacer(minLength: 400)
                    ProgressView()
                }
            }
        }
        .onAppear(perform: controller.loadSummary)
        .onAppear(perform: Notifier.shared.registerForPushNotifications)
        .onChange(of: controller.summary) { newValue in
            if newValue != nil {
                opacity = 1.0
            } else {
                opacity = 0.0
            }
        }
    }
}
