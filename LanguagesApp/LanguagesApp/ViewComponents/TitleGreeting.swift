import SwiftUI

struct TitleGreeting: View {
    let name: String
    
    var body: some View {
        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            Text(getGreeting() + "!")
                .font(.appTitle)
        } else {
            VStack {
                Text(getGreeting() + ",")
                    .font(.appTitle)
                
                Text(name)
                    .font(.appTitle)
                    .foregroundColor(.appAccent)
            }
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

