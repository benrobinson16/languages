import SwiftUI

struct TaskScreen: View {
    @StateObject private var controller = TaskController()
    
    var body: some View {
        if let summary = controller.summary {
            ScrollView {
                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        Text(summary.taskDetails.deckName)
                            .font(.appTitle)
                        
                        Spacer(minLength: 0)
                        
                        Button(action: controller.dismiss) {
                            Image(systemName: "xmark")
                                .font(.appSubheading)
                        }
                    }
                    
                    Text(summary.taskDetails.className)
                        .font(.appSubheading)
                    
                    Text("Due by: " + summary.taskDetails.dueDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.appSubheading)
                    
                    ForEach(summary.cards) { card in
                        TaskCardView(card: card)
                    }
                }
            }
            .transition(.opacity)
        } else {
            ProgressView()
        }
    }
}
