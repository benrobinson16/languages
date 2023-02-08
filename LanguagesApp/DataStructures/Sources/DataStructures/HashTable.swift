import Foundation

/// Implementation of a hash table/dictionary using an array of linked lists to resolve collisions.
public class HashTable<Key, Value>: Sequence where Key: Hashable {
    private var arr: [LinkedList<(key: Key, value: Value)>]
    private let numBins: Int
    
    /// Creates a new empty hash table.
    /// - Parameter numBins: The number of bins to provide. By default this is 1000. Must be positive.
    public init(numBins: Int = 1_000) {
        guard numBins > 0 else { fatalError("Invalid number of bins") }
        self.numBins = numBins
        
        arr = []
        for _ in 0..<numBins {
            arr.append(LinkedList<(key: Key, value: Value)>())
        }
    }
    
    public subscript(key: Key) -> Value? {
        get {
            return value(forKey: key)
        }
        set {
            set(newValue, forKey: key)
        }
    }
    
    /// Sets a value for a given key.
    /// - Parameters:
    ///   - value: The new value to set.
    ///   - key: The key. May already be in the hash table or not.
    public func set(_ value: Value?, forKey key: Key) {
        guard let value else {
            remove(key: key)
            return
        }
        
        let hash = abs(key.hashValue) % numBins
        let bin = arr[hash]
        bin.removeWhere { $0.key == key }
        
        // Chosen to prepend because frequently accessed data should be at the front.
        // Essentially this is an LRU cache where the least recently used item
        // will be at the end of the list and take the longest to find.
        bin.prepend((key, value))
    }
    
    /// Removes a given key and value from the table.
    /// - Parameter key: The key to remove.
    public func remove(key: Key) {
        let hash = abs(key.hashValue) % numBins
        let bin = arr[hash]
        bin.removeWhere { $0.key == key }
    }
    
    /// Access the value for a given key.
    /// - Parameter key: The key to use.
    /// - Returns: The value found (if any).
    public func value(forKey key: Key) -> Value? {
        let hash = abs(key.hashValue) % numBins
        let bin = arr[hash]
        let matches = bin.filter { $0.key == key }
        
        guard matches.count >= 1 else {
            return nil
        }
        
        return matches[0].value
    }
    
    /// Whether or not the dictionary contains the provided key.
    /// - Parameter key: The key to check.
    /// - Returns: True if the key exists, false if not.
    public func contains(key: Key) -> Bool {
        return value(forKey: key) != nil
    }
    
    /// Gets an array of keys in the table.
    /// - Returns: An array of keys.
    public func keys() -> [Key] {
        return kvPairs().map(\.key)
    }
    
    /// Gets an arrray of values in the table.
    /// - Returns: An array of values.
    public func values() -> [Value] {
        return kvPairs().map(\.value)
    }
    
    /// Gets an array of key value pairs from the table.
    /// - Returns: An array of keys and values.
    public func kvPairs() -> [(key: Key, value: Value)] {
        var pairs: [(key: Key, value: Value)] = []
        for bin in arr {
            pairs += bin.toArray()
        }
        return pairs
    }
    
    // MARK: - Sequence conformance
    
    // This allows the dictionary keys and values to be accessed in a for (k, v) in hashTable syntax.
    
    public func makeIterator() -> HashTableIterator<Key, Value> {
        return HashTableIterator(self)
    }
    
    public struct HashTableIterator<Key, Value>: IteratorProtocol where Key: Hashable {
        public typealias Element = (key: Key, value: Value)
        
        let pairs: [(key: Key, value: Value)]
        var index = 0
        
        init(_ hashTable: HashTable<Key, Value>) {
            self.pairs = hashTable.kvPairs()
        }
        
        public mutating func next() -> (key: Key, value: Value)? {
            if index < pairs.count {
                return pairs[index]
            } else {
                return nil
            }
        }
    }
}

extension HashTable where Value: Equatable {
    /// Checks whether the hash table contains the provided value.
    /// - Parameter value: The value to check.
    /// - Returns: True if the value if found, false if not.
    public func contains(value: Value) -> Bool {
        return values().contains(value)
    }
}
