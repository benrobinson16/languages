import SwiftUI

struct CompletionBar: View {
    let percentage: Double
    var height: Double = 24
    var cornerRadius: Double = 8
    
    var body: some View {
        GeometryReader { geom in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(.panelSecondary)
                    .frame(height: height)
            
                Rectangle()
                    .foregroundColor(.appSecondaryAccent)
                    .frame(width: geom.size.width * percentage, height: height)
                    .cornerRadius(cornerRadius)
                    .animation(.spring(dampingFraction: 0.6), value: percentage)
            }
            .cornerRadius(cornerRadius)
        }
        .frame(height: height)
    }
}
