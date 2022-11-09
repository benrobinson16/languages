import SwiftUI

struct SheetHeading: View {
    let title: String
    let dismiss: () -> Void
    
    var body: some View {
        HStack(alignment: .top) {
            Text(title)
                .font(.appTitle)
                .padding(.top)
            
            Spacer(minLength: 0)
            
            Button(action: dismiss) {
                Image(systemName: "xmark")
                    .font(.appSubheading)
                    .foregroundColor(.primary)
            }
        }
    }
}
