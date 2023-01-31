import SwiftUI

fileprivate struct KeyFrame {
    let timeOffset: Double
    let rotation: Double
    let scale: Double
    let animation: Animation?
}

/// An animated waving hand emoji.
struct WavingHand: View {
    private let keyframes = [
        KeyFrame(timeOffset: 5.0, rotation: 0.0, scale: 1.0, animation: .linear(duration: 5.0)),
        KeyFrame(timeOffset: 0.1, rotation: 25.0, scale: 1.03, animation: .linear(duration: 0.1)),
        KeyFrame(timeOffset: 0.25, rotation: -25.0, scale: 1.1, animation: .linear(duration: 0.25)),
        KeyFrame(timeOffset: 0.25, rotation: 20.0, scale: 1.05, animation: .linear(duration: 0.25)),
        KeyFrame(timeOffset: 0.25, rotation: -25.0, scale: 1.1, animation: .linear(duration: 0.25)),
        KeyFrame(timeOffset: 0.1, rotation: 0.0, scale: 1.0, animation: .easeOut(duration: 0.1))
    ]
    
    @State private var index = 0
    
    var body: some View {
        TimelineView(.cyclic(timeOffsets: keyframes.map { $0.timeOffset })) { timeline in
            Hand(date: timeline.date, keyframes: keyframes)
        }
    }
}

fileprivate struct Hand: View {
    let date: Date
    let keyframes: [KeyFrame]
    
    @State private var index = 0
    
    var body: some View {
        Text("👋")
            .font(.system(size: 52))
            .padding(.trailing, 16)
            .rotationEffect(.degrees(keyframes[index].rotation))
            .scaleEffect(keyframes[index].scale)
            .animation(keyframes[index].animation, value: index)
            .onChange(of: date) { (date: Date) in advanceKeyFrame() }
    }
    
    func advanceKeyFrame() {
        index = (index + 1) % keyframes.count
    }
}
