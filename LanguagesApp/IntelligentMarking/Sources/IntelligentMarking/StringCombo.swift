struct StringCombo: Hashable {
    let start: String
    let end: String
    
    init(_ start: String, _ end: String) {
        if start > end {
            self.start = start
            self.end = end
        } else {
            self.start = end
            self.end = start
        }
    }
}
