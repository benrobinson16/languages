import Foundation
import LanguagesAPI

class ErrorHandler: ObservableObject {
    @Published var showAlert = false
    @Published var errorMessage: String? = nil
    
    private init() { }
    public static let shared = ErrorHandler()
    
    func handleResponse(_ response: StatusResponse) {
        if !response.success {
            if let message = response.message {
                errorMessage = message
            } else {
                errorMessage = "An unexpected error occured."
            }
        }
    }
    
    func wrap(_ operation: () throws -> Void, finally: (() -> Void)? = nil) {
        do {
            try operation()
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.showAlert = true
                print(error.localizedDescription)
            }
        }
        
        finally?()
    }
    
    @MainActor
    func wrapAsync(_ operation: () async throws -> Void, finally: (() -> Void)? = nil) async {
        do {
            try await operation()
        } catch let error as AppError {
            errorMessage = error.description
            showAlert = true
        } catch {
            errorMessage = error.localizedDescription
            showAlert = true
            print(error.localizedDescription)
        }
        
        finally?()
    }
    
    func detachAsync(_ operation: @escaping () async throws -> Void, finally: (() -> Void)? = nil) {
        Task { @MainActor in
            await wrapAsync(operation, finally: finally)
        }
    }
}
