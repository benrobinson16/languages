import SwiftUI

struct CompletionBar: View {
    let percentage: Double
    var height: Double = 24
    
    var body: some View {
        GeometryReader { geom in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(.panelSecondary)
                    .frame(height: height)
            
                Rectangle()
                    .foregroundColor(.appSecondaryAccent)
                    .frame(width: geom.size.width * percentage, height: height)
                    .cornerRadius(8)
            }
            .cornerRadius(8)
        }
        .frame(height: height)
    }
}
