import SwiftUI
import SwiftData

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    @Environment(\.modelContext) private var modelContext
    @AppStorage("isUserLoggedIn") private var isUserLoggedIn: Bool = false
    @AppStorage("currentUserId") private var currentUserId: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "car.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
                .padding(.top, 40)
            
            Text("Registro de Conductor")
                .font(.largeTitle)
                .bold()
            
            TextField("Nombre del conductor", text: $viewModel.username)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .autocorrectionDisabled()
            
            TextField("Matrícula (Ej: 1234 LLL)", text: $viewModel.licensePlate)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .textInputAutocapitalization(.characters)
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Spacer()
            
            Button(action: loginUser) {
                Text("Iniciar Trayecto")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .padding()
    }
    
    func loginUser() {
        if viewModel.validate() {
            let inputName = viewModel.username.trimmingCharacters(in: .whitespaces)
            let inputPlate = viewModel.licensePlate.trimmingCharacters(in: .whitespaces)
            
            
            let predicate = #Predicate<User> { user in
                user.name == inputName && user.licensePlate == inputPlate
            }
            let descriptor = FetchDescriptor(predicate: predicate)
            
            do {
                let foundUsers = try modelContext.fetch(descriptor)
                
                if let existingUser = foundUsers.first {
                    print("Usuario encontrado: \(existingUser.name). Recuperando historial...")
                    currentUserId = existingUser.id.uuidString
                    
                } else {
                    print("Usuario nuevo. Creando registro...")
                    let newUser = User(name: inputName, licensePlate: inputPlate)
                    modelContext.insert(newUser)
                    try modelContext.save()
                    currentUserId = newUser.id.uuidString
                }
                
                isUserLoggedIn = true
                
            } catch {
                print("Error al buscar/guardar usuario: \(error)")
                viewModel.errorMessage = "Error de base de datos. Inténtalo de nuevo."
            }
        }
    }
}
