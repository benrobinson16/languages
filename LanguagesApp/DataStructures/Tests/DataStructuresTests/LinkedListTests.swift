import XCTest
@testable import DataStructures

final class LinkedListTests: XCTestCase {
    func testLinkedListInsertionRemoval() {
        let list = LinkedList<Int>()
        XCTAssertTrue(list.isEmpty)
        XCTAssertNil(list.peekFirst())
        
        // Prepend
        list.prepend(1)
        XCTAssertFalse(list.isEmpty)
        XCTAssertEqual(list[0], 1)
        XCTAssertEqual(list.count, 1)
        
        // Append
        list.append(2)
        XCTAssertEqual(list[1], 2)
        XCTAssertEqual(list.count, 2)
        
        // Replace value
        list[1] = 3
        XCTAssertEqual(list[1], 3)
        XCTAssertEqual(list.count, 2)
        
        // Remove 1
        list.remove(atPosition: 0)
        XCTAssertEqual(list[0], 3)
        XCTAssertEqual(list.count, 1)
        
        // Remove all
        list.remove(atPosition: 0)
        XCTAssertTrue(list.isEmpty)
    }
    
    func testMap() {
        let list = LinkedList<Int>(array: [0, 1, 2])
        let doubled = [0, 2, 4]
        compareArrays(list.map { $0 * 2 }.toArray(), doubled)
    }
    
    func testReduce() {
        let list = LinkedList<Int>(array: [0, 1, 2])
        XCTAssertEqual(list.reduce(initial: 0) { $0 + $1 }, 3)
    }
    
    func testFilter() {
        let list = LinkedList<Int>(array: [0, 1, 2, 3, 4])
        let evens = [0, 2, 4]
        compareArrays(list.filter { $0 % 2 == 0 }.toArray(), evens)
    }
    
    func testMinMax() {
        let list = LinkedList<Int>(array: [0, 1, 2, 3, 4]).shuffled()
        XCTAssertEqual(list.min(), 0)
        XCTAssertEqual(list.max(), 4)
    }
    
    func testRemoveWhere() {
        let odds = [1, 3]
        let list = LinkedList<Int>(array: [0, 1, 2, 3, 4])
        list.removeWhere { $0 % 2 == 0 }
        compareArrays(list.toArray(), odds)
        
        list.removeAll(ofValue: 1)
        compareArrays(list.toArray(), [3])
    }
    
    func testContains() {
        let list = LinkedList<Int>(array: [0, 1, 2, 3, 4])
        for i in 0...4 {
            XCTAssertTrue(list.contains(i))
        }
        XCTAssertFalse(list.contains(-1))
        XCTAssertFalse(list.contains(5))
    }
    
    private func compareArrays(_ arr1: [Int], _ arr2: [Int]) {
        XCTAssertEqual(arr1.count, arr2.count)
        for i in 0..<arr1.count {
            XCTAssertEqual(arr1[i], arr2[i])
        }
    }
}
