import LanguagesAPI

struct HomeInteractor {
    let appState: AppState
    
    func loadSummary() {
        guard !appState.home.isLoading else { return }
        guard let token = appState.auth.token else { return }
        appState.home.isLoading = true
        
        Task { @MainActor in
            print("running")
            do {
                appState.home.summary = try await LanguagesAPI.makeRequest(.summary(token: token))
                print(appState.home.summary)
            } catch {
                print(error)
                appState.error = "Failed to load student data."
            }
            appState.home.isLoading = false
        }
    }
}
