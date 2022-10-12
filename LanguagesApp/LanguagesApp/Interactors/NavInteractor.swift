struct NavInteractor {
    let appState: AppState
    
    func goHome() {
        appState.page = .home
    }
    
    func navigateTo(_ newPage: NavRoute) {
        appState.page = newPage
    }
}

