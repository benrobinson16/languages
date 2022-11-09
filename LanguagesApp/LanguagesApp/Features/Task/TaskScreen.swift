import SwiftUI
import LanguagesAPI

struct TaskScreen: View {
    @StateObject private var controller = TaskController()
    
    var body: some View {
        Group {
            if let summary = controller.summary {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        SheetHeading(title: summary.taskDetails.deckName, dismiss: controller.dismiss)
                        
                        TaskDetailCards(details: summary.taskDetails)
                        
                        ForEach(summary.cards) { card in
                            TaskCardView(card: card)
                        }
                    }
                    .padding()
                }
                .transition(.opacity)
            } else {
                ProgressView()
            }
        }
        .onAppear(perform: controller.loadSummary)
    }
}
