import SwiftUI

struct TitleGreeting: View {
    let name: String
    
    var body: some View {
        ZStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text(getGreeting() + ",")
                    .font(.appTitle)
                
                Text(name)
                    .font(.appTitle)
                    .foregroundColor(.appAccent)
            }
            
            HStack {
                Spacer()
                WavingHand()
            }
            .offset(y: 36)
        }
        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            Text(getGreeting() + "!")
                .font(.appTitle)
        } else {
            
        }
    }
    
    func getGreeting() -> String {
        let hour = Calendar(identifier: .gregorian).component(.hour, from: .now)
        if hour < 6 {
            return "Hi there"
        } else if hour < 12 {
            return "Good morning"
        } else if hour < 18 {
            return "Good afternoon"
        } else {
            return "Good evening"
        }
    }
}
