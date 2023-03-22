import XCTest
@testable import DataStructures

final class GraphTests: XCTestCase {
    private func initialiseTestGraph() -> Graph<Character> {
        let graph = Graph<Character>()
        
        graph.insert("q", connections: ["w", "a"])
        graph.insert("w", connections: ["q", "e", "s", "a"])
        graph.insert("e", connections: ["r", "d", "s", "w"])
        graph.insert("r", connections: ["d", "e"])
        graph.insert("d", connections: ["s", "e", "r", "x", "c"])
        graph.insert("s", connections: ["a", "w", "e", "d", "x", "z"])
        graph.insert("a", connections: ["q", "w", "s", "z"])
        graph.insert("z", connections: ["a", "s", "x"])
        graph.insert("x", connections: ["z", "s", "d", "c"])
        graph.insert("c", connections: ["x", "d"])
        
        return graph
    }
    
    func testBfs() {
        let graph = initialiseTestGraph()
        
        let expectedDistancesFromQ: [Character: Int] = [
            "q": 0,
            "w": 1,
            "e": 2,
            "r": 3,
            "a": 1,
            "s": 2,
            "d": 3,
            "z": 2,
            "x": 3,
            "c": 4
        ]
        
        for (char, dist) in expectedDistancesFromQ {
            let calculatedDistance = graph.bfs(startPos: "q", target: char)!.count - 1
            XCTAssertEqual(dist, calculatedDistance)
        }
    }
}
