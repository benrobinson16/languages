import SwiftUI
import LanguagesAPI

struct TaskList: View {
    let tasks: [TaskVm]
    let selected: (Int) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Upcoming Tasks:")
                .font(.appSubheading)
            
            if tasks.isEmpty {
                Panel {
                    HStack {
                        Spacer(minLength: 0)
                        Text("No upcoming tasks. 🎉")
                            .font(.appSubheading)
                        Spacer(minLength: 0)
                    }
                }
            } else {
                ForEach(tasks) { task in
                    TaskItem(task: task, selected: selected)
                }
            }
        }
    }
}

fileprivate struct TaskItem: View {
    let task: TaskVm
    let selected: (Int) -> Void
    
    var body: some View {
        Panel {
            HStack {
                VStack {
                    Text(task.deckName)
                        .font(.appSubheading)
                    
                    Text("\(task.className) - Due by \(task.dueDate.formatted())")
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
            }
        }
        .onTapGesture {
            selected(task.id)
        }
    }
}
