import DataStructures
import Foundation

class WeightedEditDistance {
    private let keyboard: Graph<Character>
    private var memo: [StringCombo: Int] = [:]
    
    init() {
        let path = Bundle.main.path(forResource: "keyboard", ofType: "json")!
        let url = URL(fileURLWithPath: path)
        
        do {
            let data = try Data(contentsOf: url)
            let json = try JSONDecoder().decode([String: [String]].self, from: data)
            
            // Insert each row into a hash table. Using force unwrapping because we know
            // and can assume that each string contains exactly one letter.
            let adjacencyLists = HashTable<Character, LinkedList<Character>>()
            for key in json.keys {
                let value = json[key]!.map { $0.first! }
                adjacencyLists.set(LinkedList(array: value), forKey: key.first!)
            }
            
            self.keyboard = Graph(adjacencyLists: adjacencyLists)
        } catch {
            fatalError("Failed to read in keyboard graph.")
        }
    }
    
    private func weightedEditScore(_ editType: EditType) -> Int {
        switch editType {
        case .insertion(_):
            return 3
            
        case .deletion(_):
            return 3
            
        case .substitution(let a, let b):
            if a.isLetter && b.isLetter {
                let distance = keyboard.bfs(startPos: a, target: b)!.count - 1
                return max(distance, 3)
            } else {
                return 3
            }
        }
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
            editDistance = min(
                calculate(from: start.dropLast(1), to: end) + weightedEditScore(.deletion(start.last!)),
                calculate(from: start, to: end.dropLast(1)) + weightedEditScore(.insertion(end.last!)),
                calculate(from: start.dropLast(1), to: end.dropLast(1)) + weightedEditScore(.substitution(start.last!, end.last!))
            )
        }
        
        memo[combo] = editDistance
        return editDistance
    }
}

enum EditType {
    case insertion(Character)
    case deletion(Character)
    case substitution(Character, Character)
}
