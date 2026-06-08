import Foundation
import SwiftUI
import Combine

/// Manager of the user session.
///
/// Persists the session state in `UserDefaults` via `@AppStorage`, so it is
/// preserved across app launches.
class SessionManager: ObservableObject, SessionManagerProtocol {
    @AppStorage("isUserLoggedIn") var isUserLoggedIn: Bool = false
    @AppStorage("currentUserId") var currentUserId: String = ""

    /// Marks the session as active and stores the user's identifier.
    func login(userId: String) {
        currentUserId = userId
        isUserLoggedIn = true
    }

    /// Ends the session and clears the stored identifier.
    func logout() {
        currentUserId = ""
        isUserLoggedIn = false
    }
}
