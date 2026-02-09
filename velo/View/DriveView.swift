import SwiftUI

struct DriveView: View {
    
    @StateObject private var viewModel = DriveViewModel() //initialize viewModel.
    
    var body: some View {
        ZStack{ //first at the botton
            CameraPreview(session: viewModel.cameraManager.session) //cameraview as background
                    .ignoresSafeArea() //full screen
            VStack{ //vertical organziation
                HStack{
                    Text("VELO: Active Drive")
                        .font(.headline)
                        .padding(8)
                        .background(.ultraThinMaterial) // Efecto cristal borroso
                        .cornerRadius(8)
                    Spacer()
                }
                .padding(.top, 50)
                .padding(.horizontal)
                                
                Spacer()
                
                Text("Escaneando...")
                    .foregroundColor(.white)
                    .font(.caption)
                    .padding(.bottom, 20)
            }
        }
    }
    
}

#Preview {
    DriveView()
}
