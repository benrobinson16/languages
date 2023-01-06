import SwiftUI
import SplashKit
import LanguagesUI

struct OnboardingScreen: View {
    var body: some View {
        SplashKit.SplashScreenView(SplashScreenData(
            title: (line1: "Languages", line2: "Learn your vocab"),
            titleImage: nil,
            infoContent: [
                InfoDetailData(
                    image: Image(systemName: "person.3.fill"),
                    title: "Join Classes",
                    body: "Use the join code from your teacher to view the vocabulary they set."
                ),
                InfoDetailData(
                    image: Image(systemName: "rectangle.and.pencil.and.ellipsis"),
                    title: "Question Types",
                    body: "Consolidate your learning through multiple choice and written questions with intelligent marking."
                ),
                InfoDetailData(
                    image: Image(systemName: "calendar"),
                    title: "Spaced Repetition",
                    body: "Build long term memory by dynamically reviewing the terms you're most likely to forget."
                ),
                InfoDetailData(
                    image: Image(systemName: "graduationcap"),
                    title: "Accelerate Your Learning",
                    body: "With these tools together, you'll be able to learn faster than ever before!"
                )
            ],
            buttonText: "Start Learning",
            onButtonTap: joinFirstClass,
            tintColor: .appAccent
        ))
    }
    
    func joinFirstClass() {
        Task {
            await Notifier.shared.askForPermissionIfNeeded()
            Navigator.shared.goHome()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                Navigator.shared.open(.joinClass)
            }
        }
    }
}
