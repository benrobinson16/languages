import Foundation
import SwiftUI

/// Composite component using ``CompletionBar`` to create a top bar with title and dismiss button.
public struct TopProgressBar: View {
    private let completion: Double
    private let title: String
    private let dismiss: () -> Void
    
    /// Memberwise initialiser.
    /// - Parameters:
    ///   - completion: The percentage progress. Should be between 0 and 1. Changes to this value will be animated by ``CompletionBar``.
    ///   - title: The title to display in the top-left.
    ///   - dismiss: The action to perform when the close button is tapped.
    public init(completion: Double, title: String, dismiss: @escaping () -> Void) {
        self.completion = completion
        self.title = title
        self.dismiss = dismiss
    }
    
    public var body: some View {
        VStack {
            HStack {
                Text(title)
                    .font(.appSubheading)
                
                Spacer()
                
                Button(action: dismiss) {
                    Image(systemName: "xmark")
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal)
            
            CompletionBar(percentage: completion, height: 4, cornerRadius: 0)
        }
        .background(
            Rectangle()
                .foregroundColor(.white)
        )
        .frame(height: 56)
        .frame(maxWidth: nil)
    }
}
