import SwiftUI

public struct OverdueMessageCard: View {
    private let message: String
    
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
