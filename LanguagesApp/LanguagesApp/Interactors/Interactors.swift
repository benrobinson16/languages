import SwiftUI

struct Interactors {
    let nav: NavInteractor
    let auth: AuthInteractor
    let home: HomeInteractor
    
    init(appState: AppState) {
        self.nav = .init(appState: appState)
        self.auth = .init(appState: appState)
        self.home = .init(appState: appState)
    }
}

private struct InteractorsKey: EnvironmentKey {
    static let defaultValue = Interactors(appState: AppState())
}

extension EnvironmentValues {
    var interactors: Interactors {
        get { self[InteractorsKey.self] }
        set { self[InteractorsKey.self] = newValue }
    }
}
