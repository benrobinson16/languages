import Foundation

/// Represents a type that can detect typos in student answers.
public protocol TypoDetecting {
    init(perCharacterThreshold: Double)
    func isOnlyTypo(source: String, target: String) -> Bool
}
