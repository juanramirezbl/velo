import Foundation

/// Contract for user data access.
protocol UserRepositoryProtocol {
    /// Looks up a user by name and license plate; returns `nil` if none exists.
    func findUser(name: String, licensePlate: String) throws -> User?
    /// Creates and persists a new user and returns it.
    func createUser(name: String, licensePlate: String) throws -> User
    /// Fetches a user by its string identifier.
    func fetchUser(byId id: String) -> User?
}
