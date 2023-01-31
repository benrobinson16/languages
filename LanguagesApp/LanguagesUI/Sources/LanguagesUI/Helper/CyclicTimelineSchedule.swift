import SwiftUI

/// Represents a timeline schedule that returns to the first offset entry after the final one has completed (circular).
struct CyclicTimelineSchedule: TimelineSchedule {
    fileprivate let timeOffsets: [TimeInterval]
    
    /// Conformance to the TimelineSchedule protocol by providing an iterator (`EntryIterator`) which
    /// provides access to the timeline schedule offsets.
    func entries(from startDate: Date, mode: TimelineScheduleMode) -> EntryIterator {
        EntryIterator(offsets: timeOffsets, last: startDate)
    }
    
    /// Provides access to the timeline offsets.
    struct EntryIterator: Sequence, IteratorProtocol {
        fileprivate let offsets: [TimeInterval]
        fileprivate var last: Date
        fileprivate var index: Int = -1
        
        /// Iterates the timeline offset.
        /// - Returns: The next date to update the timeline.
        mutating func next() -> Date? {
            index = (index + 1) % offsets.count
            last = last.addingTimeInterval(offsets[index])
            return last
        }
    }
}

extension TimelineSchedule where Self == CyclicTimelineSchedule {
    
    /// Convenience function for using the ``CyclicTimelineSchedule`` in SwiftUI.
    /// - Parameter timeOffsets: The seconds between each timeline update.
    /// - Returns: A ``CyclicTimelineSchedule`` which provides updates at the provided intervals.
    static func cyclic(timeOffsets: [TimeInterval]) -> CyclicTimelineSchedule {
        return CyclicTimelineSchedule(timeOffsets: timeOffsets)
    }
}
