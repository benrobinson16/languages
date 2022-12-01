import SwiftUI

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
    
    func onSelection(_ answer: String) {
        self.answer = answer
    }
}
