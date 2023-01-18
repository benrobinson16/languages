public class NoisyQueue<T>: Queue<T> {
    private let noiseFactor: Double
    
    public init(noiseFactor: Double = 0.5) {
        self.noiseFactor = noiseFactor
        
        super.init()
        
    }
    
    public init(_ list: LinkedList<T>, noiseFactor: Double = 0.5) {
        self.noiseFactor = noiseFactor
        
        super.init(list)
    }
    
    public init(_ array: [T], noiseFactor: Double = 0.5) {
        self.noiseFactor = noiseFactor
        
        super.init(array)
    }
    
    public override func dequeue() -> T? {
        var index = 0
        let maxIndex = list.count - 1
        
        while index <= maxIndex {
            // With probability noiseFactor, remove the current
            // element of the queue.
            if Double.random(in: 0...1) >= noiseFactor {
                return list.remove(atPosition: index)
            }
            index += 1
        }
        
        // In the case where none of the items have been removed,
        // return and remove the very first item like normal.
        return list.popFirst()
    }
}
