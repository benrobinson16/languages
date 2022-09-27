extension Array where Element: Equatable {
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
    func excludingEmptyElements() -> [Element] {
        return self.filter { !$0.isEmpty }
    }
}
