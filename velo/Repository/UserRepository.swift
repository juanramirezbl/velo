import Foundation
import SwiftData

/// SwiftData-backed implementation of the user repository.
class UserRepository: UserRepositoryProtocol {
    private let modelContext: ModelContext

    /// Creates the repository with the persistence context it will use.
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Looks for a user matching exactly on name and license plate.
    func findUser(name: String, licensePlate: String) throws -> User? {
        let predicate = #Predicate<User> { user in
            user.name == name && user.licensePlate == licensePlate
        }
        let descriptor = FetchDescriptor(predicate: predicate)
        let foundUsers = try modelContext.fetch(descriptor)
        return foundUsers.first
    }

    /// Creates a new user, inserts it into the context and saves the changes.
    func createUser(name: String, licensePlate: String) throws -> User {
        let newUser = User(name: name, licensePlate: licensePlate)
        modelContext.insert(newUser)
        try modelContext.save()
        return newUser
    }

    /// Fetches a user by its identifier; returns `nil` if the id is invalid or not found.
    func fetchUser(byId id: String) -> User? {
        guard let uuid = UUID(uuidString: id) else { return nil }
        let predicate = #Predicate<User> { user in
            user.id == uuid
        }
        let descriptor = FetchDescriptor(predicate: predicate)
        return try? modelContext.fetch(descriptor).first
    }
}
