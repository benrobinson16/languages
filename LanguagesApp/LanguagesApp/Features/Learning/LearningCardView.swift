import SwiftUI
import LanguagesAPI

struct LearningCardView: View {
    @ObservedObject var question: LearningQuestion
    @State private var answer = ""
    
    var body: some View {
        Panel {
            VStack {
                Text("TRANSLATE:")
                    .font(.appSecondary)
                    .foregroundColor(.secondary)
                
                Text(getQuestionString())
                
                switch question.card.nextQuestionType {
                case nil, .unspecified, .multipleChoice:
                    MultipleChoiceGrid(choices: ["1", "2", "3", "4"], answer: $answer)
                case .englishWritten, .foreignWritten:
                    WrittenResponse(answer: $answer)
                }
                
                AppButton(enabled: !answer.isEmpty, title: "Submit") {
                    question.answerQuestion(answer: answer)
                }
            }
        }
    }
    
    func getQuestionString() -> String {
        if question.card.nextQuestionType == .englishWritten {
            return question.card.foreignTerm
        } else {
            return question.card.englishTerm
        }
    }
}

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

struct ChoiceCard: View {
    let choice: String
    @Binding var answer: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .stroke(answer == choice ? Color.appAccent : Color.gray, style: .init(lineWidth: 3.0))
            
            Text(choice)
                .font(.appSubheading)
                .padding()
        }
        .onTapGesture {
            answer = choice
        }
    }
}

struct WrittenResponse: View {
    @Binding var answer: String
    
    var body: some View {
        TextField("Translation:", text: $answer)
            .textFieldStyle(RoundedBorderTextFieldStyle())
    }
}
