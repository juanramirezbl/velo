import SwiftUI
import SwiftData

@main
struct veloApp: App {
    @AppStorage("isUserLoggedIn") private var isUserLoggedIn: Bool = false
    
    var body: some Scene {
        
        WindowGroup {
            if isUserLoggedIn {
                HomeView()
                    .modelContainer(for: [User.self, Detection.self])
            } else {
                LoginView()
                    .modelContainer(for: [User.self, Detection.self])
            }
        }
    }
}
