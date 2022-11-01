import Foundation

class ErrorHandler: ObservableObject {
    @Published var errorMessage: String? = nil
    
    private init() { }
    public static let shared = ErrorHandler()
    
    func wrap(_ operation: () throws -> Void) {
        do {
            try operation()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func wrapAsync(_ operation: () async throws -> Void) async {
        do {
            try await operation()
        } catch let error as AppError {
            errorMessage = error.description
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func detachAsync(_ operation: @escaping () async throws -> Void) {
        Task {
            await wrapAsync(operation)
        }
    }
}
