struct NavInteractor {
    let appState: AppState
    
    func goHome() {
        Task { @MainActor in
            appState.page = .home
        }
    }
    
    func navigateTo(_ newPage: NavRoute) {
        Task { @MainActor in
            appState.page = newPage
        }
    }
}

