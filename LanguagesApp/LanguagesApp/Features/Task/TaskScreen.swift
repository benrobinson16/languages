import SwiftUI
import LanguagesAPI

struct TaskScreen: View {
    @StateObject private var controller = TaskController()
    
    var body: some View {
        Group {
            if let summary = controller.summary {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(alignment: .top) {
                            Text(summary.taskDetails.deckName)
                                .font(.appTitle)
                                .padding(.top)
                            
                            Spacer(minLength: 0)
                            
                            Button(action: controller.dismiss) {
                                Image(systemName: "xmark")
                                    .font(.appSubheading)
                                    .foregroundColor(.primary)
                            }
                        }
                        
                        TaskDetailsCards(details: summary.taskDetails)
                        
//                        Text("Cards:")
//                            .font(.appSubheading)
                        
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


