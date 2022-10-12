import Foundation

public protocol Queueing<Value> {
    associatedtype Value
    
    func enqueue(_ value: Value)
    func dequeue() -> Value?
    var count: Int { get }
    var isEmpty: Bool { get }
}
