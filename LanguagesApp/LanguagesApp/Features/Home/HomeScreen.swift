import SwiftUI
import LanguagesAPI
import LanguagesUI

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
                        Button {
                            nav.open(.settings)
                        } label: {
                            Image(systemName: "gear")
                                .font(.appSubheading)
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.bottom, 40)
                    
                    TitleGreeting(name: summary.studentName)
                        .padding(.bottom, 50)
                    
                    if !summary.overdueMessage.isEmpty {
                        OverdueMessageCard(message: summary.overdueMessage)
                            .onTapGesture {
                                Navigator.shared.open(.learning)
                            }
                    }
                    
                    DailyCompletionPanel(percentage: summary.dailyPercentage) { nav.open(.learning) }
                    
                    StreaksPanel(streakHistory: summary.streakHistory, streakLength: summary.streakLength)
                        .padding(.bottom, 30)
                    
                    TaskList(tasks: summary.tasks) { nav.open(.task($0)) }
                        .padding(.bottom, 30)
                    
                    ClassList(classes: summary.enrollments, joinClass: controller.joinClass, deleteEnrollment: controller.leaveClass)
                        .padding(.bottom, 30)
                    
                    HStack {
                        Spacer(minLength: 0)
                        FootnoteButton(title: "Refresh") { controller.loadSummary() }
                        Spacer(minLength: 0)
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
        .onChange(of: controller.summary) { newValue in
            if newValue != nil {
                opacity = 1.0
            } else {
                opacity = 0.0
            }
        }
    }
}
