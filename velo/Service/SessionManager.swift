import Foundation
import SwiftUI
import Combine

class SessionManager: ObservableObject, SessionManagerProtocol {
    @AppStorage("isUserLoggedIn") var isUserLoggedIn: Bool = false
    @AppStorage("currentUserId") var currentUserId: String = ""
    
    func login(userId: String) {
        currentUserId = userId
        isUserLoggedIn = true
    }
    
    func logout() {
        currentUserId = ""
        isUserLoggedIn = false
    }
}

