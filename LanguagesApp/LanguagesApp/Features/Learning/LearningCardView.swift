import SwiftUI
import LanguagesAPI

struct LearningCardView: View {
    @ObservedObject var question: LearningQuestion
    @State private var answer = ""
    
    var body: some View {
            VStack {
                Spacer(minLength: 0)
                
                Text("TRANSLATE")
                    .font(.appSecondary)
                    .foregroundColor(.secondary)
                
                Text(getQuestionString())
                    .font(.title2)
                
                Spacer(minLength: 0)
                
                switch question.card.nextQuestionType {
                case nil, .unspecified, .multipleChoice:
                    MultipleChoiceGrid(choices: ["1", "2", "3", "4"], answer: $answer)
                case .englishWritten, .foreignWritten:
                    WrittenResponse(answer: $answer)
                }
                
                Spacer(minLength: 0)
                
                AppButton(enabled: !answer.isEmpty, title: "Submit") {
                    question.answerQuestion(answer: answer)
                }
            }
            .padding()
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
                .stroke(
                    answer == choice ? Color.appAccent : Color.gray.opacity(0.75),
                    style: .init(lineWidth: answer == choice ? 4.0 : 2.0)
                )
                .animation(.spring(), value: answer)
            
            Text(choice)
                .font(.appSubheading)
                .padding()
        }
        .onTapGesture {
            answer = choice
        }
        .aspectRatio(1.0, contentMode: .fit)
    }
}

struct WrittenResponse: View {
    @Binding var answer: String
    
    var body: some View {
        TextField("Translation:", text: $answer)
            .textFieldStyle(RoundedBorderTextFieldStyle())
    }
}
