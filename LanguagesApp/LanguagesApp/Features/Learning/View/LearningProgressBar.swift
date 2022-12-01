import Foundation
import SwiftUI

struct LearningProgressBar: View {
    let completion: Double
    let mode: String
    let dismiss: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Text(mode)
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
