import SwiftUI
import LanguagesAPI
import LanguagesUI

/// Represents a question view.
struct LearningCardView: View {
    @ObservedObject var question: LearningQuestion
    @State private var answer = ""
    @FocusState private var focused: Bool?
    let next: (Bool) -> Void
    
    var body: some View {
        VStack {
            Spacer(minLength: 0)
            
            Text("TRANSLATE TO \(question.card.nextQuestionType == .englishWritten ? "ENGLISH" : "FRENCH")")
                .font(.appSecondary)
                .foregroundColor(.secondary)
            
            Text(getQuestionString())
                .font(.title2)
            
            Spacer(minLength: 0)
            
            switch question.card.nextQuestionType {
            case nil, .unspecified, .multipleChoice:
                if let options = question.card.options {
                    MultipleChoiceGrid(choices: options, answer: $answer)
                }
            case .englishWritten, .foreignWritten:
                AppTextField(focusState: $focused, text: $answer, placeholder: "Translation...")
            }
            
            Spacer(minLength: 0)
            
            AppButton(enabled: !answer.isEmpty, title: "Submit") {
                focused = nil
                question.answerQuestion(answer: answer)
            }
        }
        .padding()
        .overlay {
            Group {
                if let correct = question.correct {
                    Popup(correct: correct, feedback: question.feedback, next: { next(correct) })
                }
            }
            .animation(.spring(), value: question.correct)
        }
        .onChange(of: question.card) { _ in
            answer = ""
        }
    }
    
    /// Helper to get the correct string to display to the user.
    /// - Returns: The question string to display.
    func getQuestionString() -> String {
        if question.card.nextQuestionType == .englishWritten {
            return question.card.foreignTerm
        } else {
            return question.card.englishTerm
        }
    }
}
