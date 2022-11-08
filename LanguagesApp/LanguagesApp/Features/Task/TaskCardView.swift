import SwiftUI
import LanguagesAPI

struct TaskCardView: View {
    let card: Card
    
    var body: some View {
        Panel {
            VStack(alignment: .leading) {
                Text(card.englishTerm)
                Divider()
                Text(card.foreignTerm)
            }
        }
    }
}
