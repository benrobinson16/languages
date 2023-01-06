import SwiftUI
import LanguagesUI

struct DailyCompletionPanel: View {
    let percentage: Double
    let continueLearning: () -> Void
    
    var body: some View {
        Panel {
                VStack(alignment: .center, spacing: 16) {
                    Text(percentage.formatPercentage())
                        .font(.appTitle)
                    
                    Text("of today's cards completed")
                        .font(.appSecondary)
                        .foregroundColor(.secondary)
                    
                    CompletionBar(percentage: percentage)
                    
                    AppButton(title: "Continue learning", action: continueLearning)
                }
            }
    }
}
