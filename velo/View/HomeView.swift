
import SwiftUI
import SwiftData

struct HomeView: View {
    @AppStorage("currentUserId") private var currentUserId: String = ""
    @AppStorage("isUserLoggedIn") private var isUserLoggedIn: Bool = false
    
    @Query private var users: [User]
    
    var currentUser: User? {
        users.first { $0.id.uuidString == currentUserId }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                
                VStack(spacing: 10) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.blue)
                        .padding(.top, 40)
                    
                    Text("Ey, \(currentUser?.name ?? "Driver")")
                        .font(.title2)
                        .bold()
                    
                    HStack {
                        Image(systemName: "car.fill")
                        Text(currentUser?.licensePlate ?? "Without Plate")
                            .textCase(.uppercase)
                    }
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 5)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                
                Spacer()
                NavigationLink(destination: DashboardView()) {
                    HStack {
                        Image(systemName: "steeringwheel")
                            .font(.title)
                        Text("Start Driving")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .frame(height: 80)
                    .background(Color.blue)
                    .cornerRadius(20)
                    .shadow(radius: 5)
                }
                
                NavigationLink(destination: HistoryView(userId: currentUserId)) {
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.title)
                        Text("Historial")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.blue)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .frame(height: 80)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.blue, lineWidth: 2)
                    )
                }
                
                Spacer()
                
                Button("Log out") {
                    isUserLoggedIn = false
                }
                .foregroundColor(.red)
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 30)
            .navigationTitle("Velo")
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: User.self, inMemory: true)
}
