import SwiftUI

/// App standardised progress bar component.
public struct CompletionBar: View {
    public let percentage: Double
    public let height: Double
    public let cornerRadius: Double
    
    /// Memberwise initialiser.
    /// - Parameters:
    ///   - percentage: The current progress. Should be between 0 and 1. Changes to this value are animated with a spring animation.
    ///   - height: The heigh of the progress bar. 24 for tall bars.
    ///   - cornerRadius: The corner radius. 8 by default.
    public init(percentage: Double, height: Double = 24, cornerRadius: Double = 8) {
        self.percentage = percentage
        self.height = height
        self.cornerRadius = cornerRadius
    }
    
    public var body: some View {
        GeometryReader { geom in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(.panelSecondary)
                    .frame(height: height)
            
                Rectangle()
                    .foregroundColor(.appSecondaryAccent)
                    .frame(width: geom.size.width * percentage, height: height)
                    .cornerRadius(cornerRadius)
                    .animation(.spring(dampingFraction: 0.6), value: percentage)
            }
            .cornerRadius(cornerRadius)
        }
        .frame(height: height)
    }
}
