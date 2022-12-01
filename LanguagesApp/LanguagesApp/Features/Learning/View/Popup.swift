import SwiftUI

struct Popup: View {
    let correct: Bool
    let feedback: String?
    let next: () -> Void
    
    var body: some View {
        VStack {
            Spacer(minLength: 0)
            
            VStack(alignment: .leading) {
                Text(correct ? "Correct" : "Incorrect")
                    .font(.appTitle)
                
                if let feedback {
                    Text(feedback)
                        .font(.appSubheading)
                }
                
                AppButton(
                    enabled: true,
                    title: "Continue",
                    action: next
                )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16.0)
                    .foregroundColor(correct ? .backgroundGreen : .backgroundRed)
                    .edgesIgnoringSafeArea(.bottom)
            )
            .background(
                RoundedRectangle(cornerRadius: 16.0)
                    .foregroundColor(.init(uiColor: .systemBackground))
                    .edgesIgnoringSafeArea(.bottom)
            )
        }
        .transition(.move(edge: .bottom))
    }
}
