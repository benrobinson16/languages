import SwiftUI
import LanguagesUI

struct LearningMessageView: View {
    let message: Message
    
    var body: some View {
        VStack {
            Spacer()
            Panel {
                VStack {
                    Spacer(minLength: 0)
                    
                    Text(message.title)
                        .font(.appTitle)
                        .padding(.bottom)
                        .multilineTextAlignment(.center)
                    
                    Text(message.body)
                        .font(.appSubheading)
                        .multilineTextAlignment(.center)
                    
                    Spacer(minLength: 0)
                    
                    AppButton(title: message.option1.name, action: message.option1.action)
                    
                    if let opt2 = message.option2 {
                        AppButton(title: opt2.name, action: opt2.action)
                    }
                }
            }
            .padding()
            Spacer()
        }
    }
}
