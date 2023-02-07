/// Represents a source-destination string pairing in a hashable struct.
struct StringCombo: Hashable {
    let start: String
    let end: String
    
    /// Creates a new instance and sets the start and end values based on alphabetical order.
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
