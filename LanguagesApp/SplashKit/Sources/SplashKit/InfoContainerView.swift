import SwiftUI

struct InfoContainerView: View {
    let content: [InfoDetailData]
    let mainColor: Color
    
    init(content: [InfoDetailData], mainColor: Color) {
        self.content = content
        self.mainColor = mainColor
    }
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.fixed(100.0), spacing: 0.0, alignment: .center), GridItem(.flexible(), spacing: 0.0)], alignment: .leading, spacing: 16.0) {
            ForEach(content) { content in
                content.image
                    .font(.largeTitle)
                    .foregroundColor(mainColor)
                    .padding()
                    .accessibility(hidden: true)
                
                VStack(alignment: .leading) {
                    Text(content.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .accessibility(addTraits: .isHeader)
                    
                    Text(content.body)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding()
    }
}
