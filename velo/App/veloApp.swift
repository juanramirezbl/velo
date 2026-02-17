import SwiftUI

@main
struct veloApp: App {
    @StateObject private var dependencies = AppDependencies()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dependencies.sessionManager)
                .environmentObject(dependencies)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var dependencies: AppDependencies

    var body: some View {
        Group {
            if sessionManager.isUserLoggedIn {
                HomeView(
                    viewModel: dependencies.makeHomeViewModel()
                )
            } else {
                LoginView(
                    viewModel: dependencies.makeLoginViewModel()
                )
            }
        }
    }
}

