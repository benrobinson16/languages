import Foundation

public protocol TypoDetecting {
    func isOnlyTypo(source: String, target: String) -> Bool
}
