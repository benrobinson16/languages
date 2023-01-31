import DataStructures
import Foundation

fileprivate enum EditType {
    case insertion(Character)
    case deletion(Character)
    case substitution(Character, Character)
}

public struct WeightedEditDistance: TypoDetecting {
    private let keyboard: Graph<Character>
    private var memo: HashTable<StringCombo, Int> = .init()
    private let threshold: Double
    
    public init(perCharacterThreshold threshold: Double) {
        self.threshold = threshold
        
        let json = try! FileController().loadKeyboard()
        
        // Insert each row into a hash table. Using force unwrapping because we know
        // and can assume that each string contains exactly one letter.
        let adjacencyLists = HashTable<Character, LinkedList<Character>>()
        for key in json.keys {
            let value = json[key]!.map { $0.first! }
            adjacencyLists.set(LinkedList(array: value), forKey: key.first!)
        }
        
        self.keyboard = Graph(adjacencyLists: adjacencyLists)
    }
    
    public func isOnlyTypo(source: String, target: String) -> Bool {
        let maxDistance = threshold * Double(target.replacingOccurrences(of: " ", with: "").count)
        let distance = Double(editDistance(from: source, to: target))
        return distance <= maxDistance
    }
    
    public func editDistance(from start: String, to end: String) -> Int {
        return calculate(from: clean(s: start), to: clean(s: end))
    }
    
    private func clean(s: String) -> String {
        return s.lowercased().replacingOccurrences(of: " ", with: "")
    }
    
    private func calculate(from start: any StringProtocol, to end: any StringProtocol) -> Int {
        return calculate(from: String(start), to: String(end))
    }
        
    private func calculate(from start: String, to end: String) -> Int {
        if start == end {
            return 0
        } else if start.isEmpty {
            return calculate(from: start, to: end.dropLast(1)) + weightedEditScore(.insertion(end.last!))
        } else if end.isEmpty {
            return calculate(from: start.dropLast(1), to: end) + weightedEditScore(.deletion(start.last!))
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
            editDistance = min(
                calculate(from: start.dropLast(1), to: end) + weightedEditScore(.deletion(start.last!)),
                calculate(from: start, to: end.dropLast(1)) + weightedEditScore(.insertion(end.last!)),
                calculate(from: start.dropLast(1), to: end.dropLast(1)) + weightedEditScore(.substitution(start.last!, end.last!))
            )
        }
        
        memo[combo] = editDistance
        return editDistance
    }
    
    private func weightedEditScore(_ editType: EditType) -> Int {
        switch editType {
        case .insertion(_):
            return 3
            
        case .deletion(_):
            return 3
            
        case .substitution(let a, let b):
            if a.isLetter && b.isLetter {
                let path = keyboard.bfs(startPos: Character(a.lowercased()), target: Character(b.lowercased()))!
                let distance = path.count - 1
                return min(distance, 3)
            } else {
                return 3
            }
        }
    }
}
