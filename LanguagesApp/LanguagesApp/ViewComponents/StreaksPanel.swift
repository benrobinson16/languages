import SwiftUI
import LanguagesAPI

struct StreaksPanel: View {
    public let streakHistory: [StreakDay]
    public let streakLength: Int
    
    var body: some View {
        Panel {
            VStack(alignment: .center) {
                Text("\(streakLength) day streak")
                    .font(.appTitle)
                    .foregroundColor(.appSecondaryAccent)
                
                HStack {
                    ForEach(streakHistory, id: \.date) { history in
                        ZStack {
                            Circle()
                                .frame(width: 20, height: 20)
                                .foregroundColor(history.didAttempt ? .appAccent : .panelSecondary)
                            
                            Text(getDayLetter(date: history.date))
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(history.didAttempt ? .white : .primary)
                        }
                    }
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
