import SwiftUI

/// Provides the view for an overdue task alert.
public struct OverdueMessageCard: View {
    private let message: String
    
    /// Memberwise initialiser.
    /// - Parameter message: The message to display.
    public init(message: String) {
        self.message = message
    }
    
    public var body: some View {
        Panel(color: .backgroundRed) {
            HStack(spacing: 0) {
                Text(message)
                    .font(.appSubheading)
                    .multilineTextAlignment(.leading)
                
                Spacer(minLength: 0)
            }
        }
    }
}
