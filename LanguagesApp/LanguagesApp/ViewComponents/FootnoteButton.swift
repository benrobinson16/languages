import SwiftUI

struct FootnoteButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.appSecondary)
                .underline()
                .italic()
                .foregroundColor(.secondary)
        }
    }
}
