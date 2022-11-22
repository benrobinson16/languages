import SwiftUI

struct OverdueMessageCard: View {
    let message: String
    
    var body: some View {
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
