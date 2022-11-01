import SwiftUI

struct LearningMessageView: View {
    let message: Message
    
    var body: some View {
        Text(message.title)
    }
}

