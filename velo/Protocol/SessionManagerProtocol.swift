import Foundation

/// Contract for managing the user session.
protocol SessionManagerProtocol: ObservableObject {
    /// Indicates whether there is a logged-in user.
    var isUserLoggedIn: Bool { get set }
    /// Identifier of the current user (empty string if there is no session).
    var currentUserId: String { get set }
    /// Starts a session for the given user.
    func login(userId: String)
    /// Ends the current session.
    func logout()
}
