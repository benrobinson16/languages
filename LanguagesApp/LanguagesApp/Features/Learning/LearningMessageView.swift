import SwiftUI

struct LearningMessageView: View {
    let message: Message
    
    var body: some View {
        Panel {
            VStack {
                Text(message.title)
                    .font(.appTitle)
                
                Text(message.body)
                    .font(.appSubheading)
                
                AppButton(title: message.option1.name, action: message.option1.action)
                
                if let opt2 = message.option2 {
                    AppButton(title: opt2.name, action: opt2.action)
                }
            }
        }
    }
}

