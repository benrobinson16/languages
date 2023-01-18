import Foundation
import DataStructures

public struct EditDistance: TypoDetecting {
    private let memo: HashTable<StringCombo, Int> = .init()
    private let threshold: Double
    
    public init(perCharacterThreshold: Double) {
        self.threshold = perCharacterThreshold
    }
    
    public func isOnlyTypo(source: String, target: String) -> Bool {
        return Double(calculate(from: source, to: target)) <= threshold * Double(target.count)
    }
    
    func calculate(from start: any StringProtocol, to end: any StringProtocol) -> Int {
        return calculate(from: String(start), to: String(end))
    }
        
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
                calculate(from: start.dropLast(1), to: end),
                calculate(from: start, to: end.dropLast(1)),
                calculate(from: start.dropLast(1), to: end.dropLast(1))
            )
        }
        
        memo[combo] = editDistance
        return editDistance
    }
}
