import XCTest
@testable import DataStructures

final class HashTableTests: XCTestCase {
    func testInsertionAndRemoval() {
        insertionAndRemovalTesting(table: HashTable())
    }
    
    func testCollisionInsertionAndRemoval() {
        insertionAndRemovalTesting(table: HashTable(numBins: 2))
    }
    
    private func insertionAndRemovalTesting(table: HashTable<Int, Int>) {
        for k in 0...1000 {
            // Check this key isn't already in the table
            XCTAssertFalse(table.contains(key: k))
            XCTAssertNil(table[k])
            
            // Add the key, value
            table[k] = 2 * k
            XCTAssertTrue(table.contains(key: k))
            XCTAssertEqual(table[k], 2 * k)
        }
        
        for k in 0...1000 {
            // Check adding other keys hasn't overwritten this one
            XCTAssertTrue(table.contains(key: k))
            XCTAssertEqual(table[k], 2 * k)
            
            // Remove the key and value
            table.remove(key: k)
            XCTAssertFalse(table.contains(key: k))
            XCTAssertNil(table[k])
        }
    }
}
