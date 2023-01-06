import Foundation
import SwiftUI

public struct TopProgressBar: View {
    private let completion: Double
    private let title: String
    private let dismiss: () -> Void
    
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
