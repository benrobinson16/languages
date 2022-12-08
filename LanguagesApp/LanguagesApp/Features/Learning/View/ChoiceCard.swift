import SwiftUI

struct ChoiceCard: View {
    let choice: String
    @Binding var answer: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    answer == choice ? Color.appAccent : Color.gray.opacity(0.75),
                    style: .init(lineWidth: answer == choice ? 4.0 : 2.0)
                )
                .background(answer == choice ? Color.panelBackground : Color(uiColor: .systemBackground))
                .animation(.spring(), value: answer)
            
            Text(choice)
                .font(.appSubheading)
                .multilineTextAlignment(.center)
                .padding()
        }
        .onTapGesture {
            answer = choice
        }
        .aspectRatio(1.0, contentMode: .fit)
    }
}
