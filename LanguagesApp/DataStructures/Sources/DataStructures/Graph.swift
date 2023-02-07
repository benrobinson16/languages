import Foundation

/// Represents an unweighted network of nodes and edges using adjacency lists. Generic over the value of each node.
public class Graph<T> where T: Hashable {
    private var adjacencyLists: HashTable<T, LinkedList<T>>
    
    /// Create a new empty graph.
    public init() {
        self.adjacencyLists = .init()
    }
    
    /// Create a new graph with the provided adjacency lists pre-populated.
    /// - Parameter adjacencyLists: A ``HashTable`` mapping from node value to connected nodes.
    public init(adjacencyLists: HashTable<T, LinkedList<T>>) {
        self.adjacencyLists = adjacencyLists
    }
    
    /// Inserts a new node into the graph. This is intended as an initialisation step and therefore
    /// does not link the connected nodes back to the new node (since they may not exist yet).
    /// - Parameters:
    ///   - value: The value of the new node.
    ///   - connections: A list of connections that the new node should be connected to.
    public func insert(_ value: T, connections: LinkedList<T>) {
        adjacencyLists[value] = connections
    }
    
    /// Inserts a new node into the graph.
    /// - Parameters:
    ///   - value: The value of the new node.
    ///   - connections: A list of connections that the new node should be connected to.
    public func insert(_ value: T, connections: [T]) {
        insert(value, connections: LinkedList<T>(array: connections))
    }
    
    /// Connects two nodes with an edge. This happens in both directions.
    /// - Parameters:
    ///   - v1: The source node.
    ///   - v2: The destination node.
    public func connect(_ v1: T, and v2: T) {
        adjacencyLists[v1]?.append(v2)
        adjacencyLists[v2]?.append(v1)
    }
    
    /// Removes a node from the graph, along with any connections to/from it.
    /// - Parameter value: The value of the node to remove.
    public func remove(_ value: T) {
        for (_, connectionList) in adjacencyLists {
            connectionList.removeAll(ofValue: value)
        }
        adjacencyLists.remove(key: value)
    }
    
    /// Performs a breadth-first search on the graph.
    /// - Parameters:
    ///   - startPos: The start node.
    ///   - matches: A predicate, determining if a given value matches the target value.
    /// - Returns: A tuple with the value of the found node and the path to get there. `nil` if not found.
    public func bfs(startPos: T, _ matches: (T) -> Bool) -> (value: T, path: LinkedList<T>)? {
        let visited = LinkedList<T>()
        let queue = Queue<(value: T, path: LinkedList<T>)>()
        queue.enqueue((startPos, LinkedList<T>(array: [startPos])))
        
        while let node = queue.dequeue() {
            visited.append(node.value)
            
            // Found!
            if matches(node.value) {
                return node
            }
            
            // Add unvisited nodes to queue
            adjacencyLists[node.value]?
                .filter { !visited.contains($0) }
                .forEach { newNode in
                    let path = node.path.copy()
                    path.append(newNode)
                    queue.enqueue((newNode, path))
                }
        }
        
        return nil
    }
    
    /// Performs a depth-first search on the graph.
    /// - Parameters:
    ///   - startPos: The start node.
    ///   - matches: A predicate, determining if a given value matches the target value.
    /// - Returns: A tuple with the value of the found node and the path to get there. `nil` if not found.
    public func dfs(startPos: T, _ matches: (T) -> Bool) -> (value: T, path: LinkedList<T>)? {
        let stack = Stack<T>()
        let visited = LinkedList<T>()
        var done = false
        var current = startPos
        
        while !done {
            
            // Found!
            if matches(current) {
                return (current, stack.list)
            }
            
            // Get unvisited neighbours
            let connections = adjacencyLists[current]?
                .filter { !visited.contains($0) }
            
            guard let connections else { continue }
            
            if connections.count > 0 {
                // Go deeper into graph
                stack.push(current)
                visited.append(current)
                current = connections[0]
            } else if let last = stack.pop() {
                // Backtrack
                current = last
            } else {
                // Nowhere left to search
                done = true
            }
        }
        
        return nil
    }
}

extension Graph where T: Equatable {
    /// Performs a breadth-first search, using the equality operator to check for the target.
    /// - Parameters:
    ///   - startPos: The start node.
    ///   - target: The target/destination node.
    /// - Returns: The path to get to the target node. `nil` if not found.
    public func bfs(startPos: T, target: T) -> LinkedList<T>? {
        return bfs(startPos: startPos, { $0 == target})?.path
    }
    
    /// Performs a depth-first search, using the equality operator to check for the target.
    /// - Parameters:
    ///   - startPos: The start node.
    ///   - target: The target/destination node.
    /// - Returns: The path to get to the target node. `nil` if not found.
    public func dfs(startPos: T, target: T) -> LinkedList<T>? {
        return dfs(startPos: startPos, { $0 == target})?.path
    }
}
