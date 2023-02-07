import Foundation
import DataStructures

/// Calculates (unweighted) edit distance between answers.
public struct EditDistance: TypoDetecting {
    private let memo: HashTable<StringCombo, Int> = .init()
    private let threshold: Double
    
    /// Creates a new instance.
    /// - Parameter perCharacterThreshold: The allowed insetions/deletions/substitutions per character to be marked a typo.
    public init(perCharacterThreshold: Double) {
        self.threshold = perCharacterThreshold
    }
    
    /// Determines if a student answer is simply a typo of a correct answer.
    /// - Parameters:
    ///   - source: The student answer.
    ///   - target: The target answer.
    /// - Returns: Whether it is likely just a typo.
    public func isOnlyTypo(source: String, target: String) -> Bool {
        return Double(calculate(from: source, to: target)) <= threshold * Double(target.count)
    }
    
    /// Calculates edit distance between two answers.
    /// - Parameters:
    ///   - start: The starting string.
    ///   - end: The target string.
    /// - Returns: The number of insertions/deletions/substitutions required.
    func calculate(from start: any StringProtocol, to end: any StringProtocol) -> Int {
        return calculate(from: String(start), to: String(end))
    }
    
    /// Calculates edit distance between two answers.
    /// - Parameters:
    ///   - start: The starting string.
    ///   - end: The target string.
    /// - Returns: The number of insertions/deletions/substitutions required.
    func calculate(from start: String, to end: String) -> Int {
        if start.isEmpty || end.isEmpty {
            return max(start.count, end.count)
        }
        
        // Check memo
        let combo = StringCombo(start, end)
        if let precalculated = memo[combo] {
            return precalculated
        }
        
        var editDistance = 0
        if start.last == end.last {
            editDistance = calculate(from: start.dropLast(1), to: end.dropLast(1))
        } else {
            editDistance = 1 + min(
                calculate(from: start.dropLast(1), to: end), // deletion
                calculate(from: start, to: end.dropLast(1)), // insertion
                calculate(from: start.dropLast(1), to: end.dropLast(1)) // substitution
            )
        }
        
        memo[combo] = editDistance
        return editDistance
    }
}
