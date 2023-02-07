import Foundation
import LanguagesAPI

/// Global class to wrap errors and display an alert.
class ErrorHandler: ObservableObject {
    @Published var showAlert = false
    @Published var errorMessage: String? = nil
    
    private init() { }
    public static let shared = ErrorHandler()
    
    /// Hide the error alert.
    func dismiss() {
        showAlert = false
    }
    
    /// Handle a status response and display an alert if there is an error.
    /// - Parameter response: The status response.
    func handleResponse(_ response: StatusResponse) {
        if !response.success {
            DispatchQueue.main.async {
                self.errorMessage = response.message ?? "An unexpected error occurred."
                self.showAlert = true
            }
        }
    }
    
    /// Handle an error and display an alert.
    /// - Parameter error: The error that has occurred.
    func report(_ error: Error?) {
        if let error {
            errorMessage = error.localizedDescription
        } else {
            errorMessage = "An unexpected error occurred."
        }
        self.showAlert = true
    }
    
    /// Operates like a do-catch block with errors resulting in an alert.
    /// - Parameters:
    ///   - operation: The throwing operation.
    ///   - finally: Clean-up operations.
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
    
    /// Operates like a do-catch block with errors resulting in an alert.
    /// - Parameters:
    ///   - operation: The asynchronous throwing operation.
    ///   - finally: Clean-up operations.
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
    
    /// Operates like a do-catch block with errors resulting in an alert. Creates a task to run an operation detached.
    /// - Parameters:
    ///   - operation: The asynchronous throwing operation.
    ///   - finally: Clean-up operations.
    func detachAsync(_ operation: @escaping () async throws -> Void, finally: (() -> Void)? = nil) {
        Task { @MainActor in
            await wrapAsync(operation, finally: finally)
        }
    }
}
