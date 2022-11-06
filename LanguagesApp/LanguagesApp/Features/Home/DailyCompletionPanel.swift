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
                    
                    GeometryReader { geom in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .foregroundColor(.panelSecondary)
                                .frame(height: 24)
                        
                            Rectangle()
                                .foregroundColor(.appSecondaryAccent)
                                .frame(width: geom.size.width * percentage, height: 24)
                                .cornerRadius(8)
                        }
                        .cornerRadius(8)
                    }
                    .frame(height: 24)
                    
                    AppButton(title: "Continue learning", action: continueLearning)
                }
            }
    }
}
