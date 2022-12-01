import Foundation

public struct IntelligentMarking {
    private let answerGenerator: AnswerGenerating
    private let typoDetector: TypoDetecting
    
    public init(answerGenerator: AnswerGenerating, typoDetector: TypoDetecting) {
        self.answerGenerator = answerGenerator
        self.typoDetector = typoDetector
    }
    
    public func isCorrect(userAnswer: String, teacherAnswer: String, language: String) -> Bool {
        return isCorrectFeedback(userAnswer: userAnswer, teacherAnswer: teacherAnswer, language: language).isCorrect
    }
    
    public func isCorrectFeedback(userAnswer: String, teacherAnswer: String, language: String) -> (isCorrect: Bool, correction: String?) {
        let cleanedUserAnswer = clean(answer: userAnswer)
        let cleanedTeacherAnswer = clean(answer: teacherAnswer)
        
        let possibleAnswers = answerGenerator.generate(answer: cleanedTeacherAnswer, language: language)
        if possibleAnswers.contains(cleanedUserAnswer) { return (true, nil) }
        
        for possibleAnswer in possibleAnswers {
            if typoDetector.isOnlyTypo(source: cleanedUserAnswer, target: possibleAnswer) {
                return (true, possibleAnswer)
            }
        }
        
        return (false, possibleAnswers.randomElement())
    }
    
    private func clean(answer: String) -> String {
        return answer
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .applyingTransform(.stripDiacritics, reverse: false)!
            .applyingTransform(.toLatin, reverse: false)!
            .lowercased()
            .replacingOccurrences(of: "’", with: "'")
            .replacingOccurrences(of: "“", with: "\"")
            .replacingOccurrences(of: "”", with: "\"")
    }
}
