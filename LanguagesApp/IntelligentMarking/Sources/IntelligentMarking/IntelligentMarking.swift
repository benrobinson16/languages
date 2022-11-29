import Foundation

public struct IntelligentMarking {
    private let answerGenerator: AnswerGenerating
    private let typoDetector: TypoDetecting
    
    public init(answerGenerator: AnswerGenerating, typoDetector: TypoDetecting) {
        self.answerGenerator = answerGenerator
        self.typoDetector = typoDetector
    }
    
    public func isCorrect(userAnswer: String, teacherAnswer: String) -> Bool {
        let cleanedUserAnswer = userAnswer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let cleanedTeacherAnswer = teacherAnswer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        let possibleAnswers = answerGenerator.generate(answer: cleanedTeacherAnswer)
        if possibleAnswers.contains(cleanedUserAnswer) { return true }
        
        for possibleAnswer in possibleAnswers {
            if typoDetector.isOnlyTypo(source: cleanedUserAnswer, target: possibleAnswer) {
                return true
            }
        }
        
        return false
    }
}
