import Foundation

public class Graph<T> where T: Hashable {
    var adjacencyLists: HashTable<T, LinkedList<T>>
    
    public init() {
        self.adjacencyLists = .init()
    }
    
    public init(adjacencyLists: HashTable<T, LinkedList<T>>) {
        self.adjacencyLists = adjacencyLists
    }
    
    public func insert(_ value: T, connections: LinkedList<T>) {
        adjacencyLists[value] = connections
    }
    
    public func insert(_ value: T, connections: [T]) {
        insert(value, connections: LinkedList<T>(array: connections))
    }
    
    public func connect(_ v1: T, and v2: T) {
        adjacencyLists[v1].append(v2)
        adjacencyLists[v2].append(v1)
    }
    
    public func remove(_ value: T) {
        for (_, connectionList) in adjacencyLists {
            connectionList.removeAll(ofValue: value)
        }
        adjacencyLists.remove(key: value)
    }
    
    public func bfs(startPos: T, _ matches: (T) -> Bool) -> (value: T, path: LinkedList<T>)? {
        let visited = LinkedList<T>()
        let queue = Queue<(value: T, path: LinkedList<T>)>()
        queue.enqueue((startPos, LinkedList<T>(array: [startPos])))
        
        while let node = queue.dequeue() {
            visited.append(node.value)
            
            if matches(node.value) {
                return node
            }
            
            adjacencyLists[node.value]
                .filter { !visited.contains($0) }
                .forEach { newNode in
                    let path = node.path.copy()
                    path.append(newNode)
                    queue.enqueue((newNode, path))
                }
        }
        
        return nil
    }
    
    public func dfs(startPos: T, _ matches: (T) -> Bool) -> (value: T, path: LinkedList<T>)? {
        let stack = Stack<T>()
        let visited = LinkedList<T>()
        var done = false
        var current = startPos
        
        while !done {
            if matches(current) {
                return (current, stack.list)
            }
            
            let connections = adjacencyLists[current]
                .filter { !visited.contains($0) }
            
            if connections.count > 0 {
                stack.push(current)
                visited.append(current)
                current = connections[0]
            } else if let last = stack.pop() {
                current = last
            } else {
                done = true
            }
        }
        
        return nil
    }
}

extension Graph where T: Equatable {
    public func bfs(startPos: T, target: T) -> LinkedList<T>? {
        return bfs(startPos: startPos, { $0 == target})?.path
    }
    
    public func dfs(startPos: T, target: T) -> LinkedList<T>? {
        return dfs(startPos: startPos, { $0 == target})?.path
    }
}
