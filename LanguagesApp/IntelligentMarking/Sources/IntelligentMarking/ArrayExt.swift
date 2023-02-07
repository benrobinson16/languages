extension Array where Element: Equatable {
    /// Creates a new array with only unique elements.
    /// - Returns: A new array with unique elements.
    func unique() -> [Element] {
        var duplicatesRemoved: [Element] = []
        for element in self {
            if !duplicatesRemoved.contains(element) {
                duplicatesRemoved.append(element)
            }
        }
        return duplicatesRemoved
    }
}

extension Array where Element: Collection {
    /// Helper function to return an array of only elements that are not empty.
    /// - Returns: An array of non-empty elements.
    func excludingEmptyElements() -> [Element] {
        return self.filter { !$0.isEmpty }
    }
}
