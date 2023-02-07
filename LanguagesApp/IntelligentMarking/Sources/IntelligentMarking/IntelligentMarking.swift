import Foundation

/// Marks an answer as correct/incorrect and provides feedback.
public struct IntelligentMarking {
    private let answerGenerator: AnswerGenerating
    private let typoDetector: TypoDetecting
    
    /// Creates a new instance with the provided dependencies.
    /// - Parameters:
    ///   - answerGenerator: An instance to generate possible answers.
    ///   - typoDetector: An instance to detect typos in user answers.
    public init(answerGenerator: AnswerGenerating, typoDetector: TypoDetecting) {
        self.answerGenerator = answerGenerator
        self.typoDetector = typoDetector
    }
    
    /// Decides if a student answer is correct.
    /// - Parameters:
    ///   - userAnswer: The student's answer.
    ///   - teacherAnswer: The teacher's answer.
    ///   - language: The  language being used (for article dropping).
    /// - Returns: Whether or not the student answer is correct.
    public func isCorrect(userAnswer: String, teacherAnswer: String, language: String) -> Bool {
        return isCorrectFeedback(userAnswer: userAnswer, teacherAnswer: teacherAnswer, language: language).isCorrect
    }
    
    /// Decides if a student answer is correct, and provides feedback.
    /// - Parameters:
    ///   - userAnswer: The student's answer.
    ///   - teacherAnswer: The teacher's answer.
    ///   - language: The  language being used (for article dropping).
    /// - Returns: A tuple with whether or not the student is correct and any feedback (e.g. correct answer, typo detected) provided.
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
    
    /// Removes problem characters from an answer.
    /// - Parameter answer: The answer to clean.
    /// - Returns: An answer trimmed of leading/trailing whitespace and special characters.
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
