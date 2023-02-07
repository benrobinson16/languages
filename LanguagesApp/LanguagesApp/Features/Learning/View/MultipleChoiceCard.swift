import SwiftUI

/// Represents a grid of multiple choice options.
struct MultipleChoiceGrid: View {
    let choices: [String]
    @Binding var answer: String
    
    var body: some View {
        VStack {
            HStack {
                ChoiceCard(choice: choices[0], answer: $answer)
                ChoiceCard(choice: choices[1], answer: $answer)
            }
            HStack {
                ChoiceCard(choice: choices[2], answer: $answer)
                ChoiceCard(choice: choices[3], answer: $answer)
            }
        }
    }
    
    /// Indicates the user has tapped an answer.
    /// - Parameter answer: The answer that was tapped.
    func onSelection(_ answer: String) {
        self.answer = answer
    }
}
