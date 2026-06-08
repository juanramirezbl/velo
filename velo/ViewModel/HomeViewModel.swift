import Foundation
import Combine

/// ViewModel for the home screen.
///
/// Loads the logged-in user and handles logging out.
class HomeViewModel: ObservableObject {
    @Published var currentUser: User?

    private let userRepository: UserRepositoryProtocol
    private let sessionManager: SessionManagerProtocol

    /// Identifier of the logged-in user.
    var currentUserId: String {
        sessionManager.currentUserId
    }

    /// Injects dependencies and loads the current user from the session.
    init(userRepository: UserRepositoryProtocol, sessionManager: SessionManagerProtocol) {
        self.userRepository = userRepository
        self.sessionManager = sessionManager
        self.currentUser = userRepository.fetchUser(byId: sessionManager.currentUserId)
    }

    /// Logs out the current user.
    func logout() {
        sessionManager.logout()
    }
}
