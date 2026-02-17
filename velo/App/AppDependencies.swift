import Foundation
import SwiftData
import Combine
@MainActor
class AppDependencies : ObservableObject {
    let modelContainer: ModelContainer
    let modelContext: ModelContext
    let sessionManager: SessionManager

    private let userRepository: UserRepositoryProtocol
    private let detectionRepository: DetectionRepositoryProtocol

    init() {
        self.modelContainer = try! ModelContainer(for: User.self, Detection.self)
        self.modelContext = modelContainer.mainContext
        self.sessionManager = SessionManager()
        self.userRepository = UserRepository(modelContext: modelContext)
        self.detectionRepository = DetectionRepository(modelContext: modelContext)
    }

    // MARK: - ViewModel Factories

    func makeLoginViewModel() -> LoginViewModel {
        LoginViewModel(
            userRepository: userRepository,
            sessionManager: sessionManager
        )
    }

    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            userRepository: userRepository,
            sessionManager: sessionManager
        )
    }

    func makeDashboardViewModel() -> DashboardViewModel {
        DashboardViewModel(
            detectionRepository: detectionRepository,
            userRepository: userRepository,
            sessionManager: sessionManager
        )
    }

    func makeHistoryViewModel(userId: String) -> HistoryViewModel {
        HistoryViewModel(
            userId: userId,
            detectionRepository: detectionRepository
        )
    }
}

