import Foundation
import SwiftData

class UserRepository: UserRepositoryProtocol {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func findUser(name: String, licensePlate: String) throws -> User? {
        let predicate = #Predicate<User> { user in
            user.name == name && user.licensePlate == licensePlate
        }
        let descriptor = FetchDescriptor(predicate: predicate)
        let foundUsers = try modelContext.fetch(descriptor)
        return foundUsers.first
    }
    
    func createUser(name: String, licensePlate: String) throws -> User {
        let newUser = User(name: name, licensePlate: licensePlate)
        modelContext.insert(newUser)
        try modelContext.save()
        return newUser
    }
    
    func fetchUser(byId id: String) -> User? {
        guard let uuid = UUID(uuidString: id) else { return nil }
        let predicate = #Predicate<User> { user in
            user.id == uuid
        }
        let descriptor = FetchDescriptor(predicate: predicate)
        return try? modelContext.fetch(descriptor).first
    }
}

