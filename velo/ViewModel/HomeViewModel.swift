import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var currentUser: User?
    
    private let userRepository: UserRepositoryProtocol
    private let sessionManager: SessionManagerProtocol
    
    var currentUserId: String {
        sessionManager.currentUserId
    }
    
    init(userRepository: UserRepositoryProtocol, sessionManager: SessionManagerProtocol) {
        self.userRepository = userRepository
        self.sessionManager = sessionManager
        self.currentUser = userRepository.fetchUser(byId: sessionManager.currentUserId)
    }
    
    func logout() {
        sessionManager.logout()
    }
}

