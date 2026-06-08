import Foundation
import Combine

/// ViewModel for the registration / login screen.
///
/// Validates the entered data and, depending on whether the user exists,
/// retrieves or creates it.
class LoginViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var licensePlate: String = ""
    @Published var errorMessage: String? = nil

    private let userRepository: UserRepositoryProtocol
    private let sessionManager: SessionManagerProtocol

    /// Injects the user repository and the session manager.
    init(userRepository: UserRepositoryProtocol, sessionManager: SessionManagerProtocol) {
        self.userRepository = userRepository
        self.sessionManager = sessionManager
    }

    /// Checks that the name and license plate are not empty.
    /// - Returns: `true` if the data is valid; `false` and an error message otherwise.
    func validate() -> Bool {
        if username.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Por favor, introduce un nombre para continuar."
            return false
        }
        if licensePlate.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "La matrícula es obligatoria para registrar el trayecto."
            return false
        }
        errorMessage = nil
        return true
    }

    /// Starts the trip: reuses the user if it already exists or creates a new one, and logs in.
    func loginUser() {
        guard validate() else { return }

        let inputName = username.trimmingCharacters(in: .whitespaces)
        let inputPlate = licensePlate.trimmingCharacters(in: .whitespaces)

        do {
            if let existingUser = try userRepository.findUser(name: inputName, licensePlate: inputPlate) {
                print("Usuario encontrado: \(existingUser.name). Recuperando historial...")
                sessionManager.login(userId: existingUser.id.uuidString)
            } else {
                print("Usuario nuevo. Creando registro...")
                let newUser = try userRepository.createUser(name: inputName, licensePlate: inputPlate)
                sessionManager.login(userId: newUser.id.uuidString)
            }
        } catch {
            print("Error al buscar/guardar usuario: \(error)")
            errorMessage = "Error de base de datos. Inténtalo de nuevo."
        }
    }
}

