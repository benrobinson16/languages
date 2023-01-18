import Foundation

public protocol TypoDetecting {
    init(perCharacterThreshold: Double)
    func isOnlyTypo(source: String, target: String) -> Bool
}
