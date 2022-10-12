import SwiftUI

struct SplashScreen: View {
    var body: some View {
        VStack(alignment: .center) {
            Text("Languages")
                .font(.largeTitle)
            
            ZStack {
                RoundedRectangle(cornerRadius: UIScreen.main.bounds.width, style: .continuous)
                    .foregroundColor(.blue)
                    .frame(width: UIScreen.main.bounds.width * 2, height: UIScreen.main.bounds.width * 2)
                    .offset(y: 300)
                    .ignoresSafeArea()
                
                SignInButton()
                    .offset(y: 150)
            }
        }
        .padding()
    }
}
