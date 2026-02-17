import SwiftUI
import SwiftData

@main
struct veloApp: App {
    @StateObject private var sessionManager = SessionManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [User.self, Detection.self])
                .environmentObject(sessionManager)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        Group {
            if sessionManager.isUserLoggedIn {
                HomeView(
                    viewModel: HomeViewModel(
                        userRepository: UserRepository(modelContext: modelContext),
                        sessionManager: sessionManager
                    )
                )
            } else {
                LoginView(
                    viewModel: LoginViewModel(
                        userRepository: UserRepository(modelContext: modelContext),
                        sessionManager: sessionManager
                    )
                )
            }
        }
    }
}

