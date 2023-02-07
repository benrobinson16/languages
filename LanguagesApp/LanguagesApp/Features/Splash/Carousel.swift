import SwiftUI

/// Represents a rotating carousel view of words.
struct Carousel: View  {
    @State private var words: [Word]
    private let delay: Double
    private let font: Font
    private let moveLeft: Bool
    
    /// Creates a new carousel.
    /// - Parameters:
    ///   - words: The words in the carousel.
    ///   - delay: The delay between rotations.
    ///   - font: The font of each word.
    ///   - moveLeft: Whether the carousel should rotate left (false = right).
    init(words: [String], delay: Double, font: Font, moveLeft: Bool) {
        self.words = words.map { .init(content: $0) }
        self.delay = delay
        self.font = font
        self.moveLeft = moveLeft
    }
    
    var body: some View {
        TimelineView(.periodic(from: .now.addingTimeInterval(-delay), by: 6.0)) { timeline in
            WordList(date: timeline.date, words: $words, font: font, moveLeft: moveLeft)
        }
    }
}

/// Represents a horizontal stack of words.
fileprivate struct WordList: View {
    let date: Date
    
    @Binding var words: [Word]
    @State private var limbo: Word? = nil
    
    let font: Font
    let moveLeft: Bool
    
    var body: some View {
        HStack(spacing: 32.0) {
            ForEach(Array(words.enumerated()), id: \.element) { idx, word in
                Text(word.content)
                    .font(font)
                    .lineLimit(1)
                    .fixedSize()
                    .transition(.asymmetric(
                        insertion: .opacity,
                        removal: .opacity.combined(with: .move(edge: moveLeft ? .leading : .trailing))
                    ))
                    .animation(.spring(dampingFraction: 0.6).delay(Double(moveLeft ? idx : words.count - idx - 1) * 0.1), value: words)
            }
        }
        .edgesIgnoringSafeArea(.trailing)
        .onChange(of: date, perform: increment)
    }
    
    /// Move to the next time step.
    /// - Parameter newDate: The new timestep.
    func increment(_ newDate: Date) {
        withAnimation {
            if moveLeft {
                if let limbo { words.append(limbo) }
                limbo = words.removeFirst()
            } else {
                if let limbo { words.insert(limbo, at: 0) }
                limbo = words.removeLast()
            }
        }
    }
}

/// Represents a single word for the carousel.
fileprivate struct Word: Identifiable, Equatable, Hashable {
    let content: String
    
    var id: String { return content }
}
