import SwiftUI
import LanguagesAPI

/// The task details screen.
struct TaskScreen: View {
    @ObservedObject private var nav = Navigator.shared
    @StateObject private var controller = TaskController()
    
    var body: some View {
        Group {
            if let summary = controller.summary {
                NavigationView {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            TaskDetailCards(details: summary.taskDetails)
                            
                            ForEach(summary.cards) { card in
                                TaskCardView(card: card)
                            }
                        }
                        .padding()
                    }
                    .transition(.opacity)
                    .navigationTitle(Text(summary.taskDetails.deckName))
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: nav.goHome) {
                                Text("Close")
                            }
                        }
                    }
                }
            } else {
                ProgressView()
            }
        }
        .onAppear(perform: controller.loadSummary)
    }
}
