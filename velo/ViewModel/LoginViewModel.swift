import Foundation
import Combine

class LoginViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var licensePlate: String = ""
    @Published var errorMessage: String? = nil
    
    private let userRepository: UserRepositoryProtocol
    private let sessionManager: SessionManagerProtocol
    
    init(userRepository: UserRepositoryProtocol, sessionManager: SessionManagerProtocol) {
        self.userRepository = userRepository
        self.sessionManager = sessionManager
    }
    
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

