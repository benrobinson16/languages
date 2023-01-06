import SwiftUI
import LanguagesAPI
import LanguagesUI

struct StreaksPanel: View {
    public let streakHistory: [StreakDay]
    public let streakLength: Int
    
    var body: some View {
        Panel {
            VStack(alignment: .center, spacing: 16) {
                Text("\(streakLength) day")
                    .font(.appTitle)
                
                Text("continuous practice streak")
                    .font(.appSecondary)
                    .foregroundColor(.secondary)
                
                HStack {
                    ForEach(streakHistory.reversed(), id: \.date) { history in
                        Spacer()
                        ZStack {
                            Circle()
                                .frame(height: 42)
                                .foregroundColor(history.didAttempt ? .appAccent : .panelSecondary)
                            
                            Text(getDayLetter(date: history.date))
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .foregroundColor(history.didAttempt ? .white : .primary)
                        }
                    }
                    Spacer()
                }
            }
        }
    }
    
    func getDayLetter(date: Date) -> String {
        let weekday = Calendar(identifier: .gregorian).component(.weekday, from: date)
        switch weekday {
        case 1, 7:
            return "S"
        case 2:
            return "M"
        case 3, 5:
            return "T"
        case 4:
            return "W"
        case 6:
            return "F"
        default:
            return ""
        }
    }
}
