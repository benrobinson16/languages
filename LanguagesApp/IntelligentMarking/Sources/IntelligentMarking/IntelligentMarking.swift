import Foundation

public struct IntelligentMarking {
    private let answerGenerator: AnswerGenerating
    private let typoDetector: TypoDetecting
    
    public init(answerGenerator: AnswerGenerating, typoDetector: TypoDetecting) {
        self.answerGenerator = answerGenerator
        self.typoDetector = typoDetector
    }
    
    public func isCorrect(userAnswer: String, teacherAnswer: String) -> Bool {
        let possibleAnswers = answerGenerator.generate(answer: teacherAnswer)
        if possibleAnswers.contains(userAnswer) { return true }
        
        for possibleAnswer in possibleAnswers {
            if typoDetector.isOnlyTypo(source: userAnswer, target: possibleAnswer) {
                return true
            }
        }
        
        return false
    }
}
