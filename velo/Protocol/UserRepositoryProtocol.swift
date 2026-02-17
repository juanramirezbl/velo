import Foundation

protocol UserRepositoryProtocol {
    func findUser(name: String, licensePlate: String) throws -> User?
    func createUser(name: String, licensePlate: String) throws -> User
    func fetchUser(byId id: String) -> User?
}

