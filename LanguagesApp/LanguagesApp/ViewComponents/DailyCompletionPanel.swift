import SwiftUI

struct DailyCompletionPanel: View {
    let percentage: Double
    let continueLearning: () -> Void
    
    var body: some View {
        Panel {
            VStack(alignment: .center) {
                Text(percentage.formatted(.percent))
                    .font(.appTitle)
                
                Text("of today's cards completed")
                    .font(.appSecondary)
                    .foregroundColor(.secondary)
                
                GeometryReader { geom in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .foregroundColor(.panelSecondary)
                        
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .frame(width: geom.size.width * percentage)
                            .foregroundColor(.appSecondaryAccent)
                    }
                }
                
                AppButton(title: "Continue learning", action: continueLearning)
            }
        }
    }
}
