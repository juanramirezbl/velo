import Foundation

protocol SessionManagerProtocol: ObservableObject {
    var isUserLoggedIn: Bool { get set }
    var currentUserId: String { get set }
    func login(userId: String)
    func logout()
}

