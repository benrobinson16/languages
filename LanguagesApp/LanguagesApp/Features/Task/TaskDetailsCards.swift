import SwiftUI
import LanguagesAPI

struct TaskDetailCards: View {
    let details: TaskVm
    
    var body: some View {
        if let completion = details.completion {
            Panel {
                VStack(alignment: .center, spacing: 8.0) {
                    Text(completion.formatted(.percent))
                        .font(.appTitle)
                        .foregroundColor(.appSecondaryAccent)
                    
                    Text("of the task completed")
                        .font(.appSecondary)
                        .foregroundColor(.secondary)
                    
                    CompletionBar(percentage: completion)
                }
            }
        }
        
        Panel {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Deck: ") + Text(details.deckName)
                        .fontWeight(.medium)
                    Text("Set for: ") + Text(details.className)
                        .fontWeight(.medium)
                    Text("Due by: ") + Text(details.dueDate.appFormat())
                        .fontWeight(.medium)
                        .foregroundColor(details.dueDate < .now ? .red : .primary)
                }
                Spacer(minLength: 0)
            }
        }
    }
}
