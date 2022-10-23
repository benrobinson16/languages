import SwiftUI
import LanguagesAPI

struct TaskList: View {
    let tasks: [TaskVm]
    let selected: (Int) -> Void
    
    var body: some View {
        VStack {
            Text("Upcoming Tasks")
                .font(.appSubheading)
            
            ForEach(tasks) { task in
                TaskItem(task: task, selected: selected)
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
