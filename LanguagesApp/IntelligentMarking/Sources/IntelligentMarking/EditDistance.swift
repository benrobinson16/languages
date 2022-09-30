class EditDistance {
    private var memo: [StringCombo: Int] = [:]
    
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
