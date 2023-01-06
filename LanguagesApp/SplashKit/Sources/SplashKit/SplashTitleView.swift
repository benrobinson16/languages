import SwiftUI

struct SplashTitleView: View {
    let title: (line1: String, line2: String)
    let image: AnyView?
    let mainColor: Color
    
    init(title: (line1: String, line2: String), image: AnyView?, mainColor: Color) {
        self.title = title
        self.image = image
        self.mainColor = mainColor
    }
    
    public var body: some View {
        VStack {
            if let image = image {
                image
                    .accessibility(hidden: true)
            }
            
            Text(title.line1)
                .font(.system(size: 36, weight: .black, design: .rounded))
            
            Text(title.line2)
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundColor(mainColor)
        }
    }
}
