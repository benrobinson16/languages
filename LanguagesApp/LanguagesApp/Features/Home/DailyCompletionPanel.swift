import SwiftUI

struct DailyCompletionPanel: View {
    let percentage: Double
    let continueLearning: () -> Void
    
    var body: some View {
        Panel {
            VStack(alignment: .center, spacing: 16) {
                Text(percentage.formatted(.percent))
                    .font(.appTitle)
                
                Text("of today's cards completed")
                    .font(.appSecondary)
                    .foregroundColor(.secondary)
                
                ZStack(alignment: .leading) {
                    Rectangle()
                        .foregroundColor(.panelSecondary)
                        .cornerRadius(8)
                        .frame(height: 24)
                    
                    Rectangle()
                        .scaleEffect(x: percentage)
                        .foregroundColor(.appSecondaryAccent)
                        .cornerRadius(8)
                        .frame(height: 24)
                }
                
                AppButton(title: "Continue learning", action: continueLearning)
            }
        }
    }
}
