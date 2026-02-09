import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @StateObject private var cameraManager = CameraManager()
    
    @AppStorage("currentUserId") private var currentUserId: String = ""
    
    @Query private var users: [User]
    
    var currentUser: User? {
        users.first { $0.id.uuidString == currentUserId }
    }

    func calculateBox(for detection: DetectedObject, in geometry: GeometryProxy) -> CGRect {
        let screenWidth = geometry.size.width
        let screenHeight = geometry.size.height
        let videoWidth: CGFloat = 1080
        let videoHeight: CGFloat = 1920
        
        let screenAspectRatio = screenWidth / screenHeight
        let videoAspectRatio = videoWidth / videoHeight
        
        var scale: CGFloat
        var xOffset: CGFloat = 0
        var yOffset: CGFloat = 0
        
        if screenAspectRatio < videoAspectRatio {
            scale = screenHeight / videoHeight
            let scaledWidth = videoWidth * scale
            xOffset = (scaledWidth - screenWidth) / 2
        } else {
            scale = screenWidth / videoWidth
            let scaledHeight = videoHeight * scale
            yOffset = (scaledHeight - screenHeight) / 2
        }
        
        let rect = detection.rect
        let width = rect.width * videoWidth * scale
        let height = rect.height * videoHeight * scale
        let x = (rect.minX * videoWidth * scale) - xOffset
        let y = (screenHeight - (rect.minY * videoHeight * scale) - height) + yOffset
        
        return CGRect(x: x, y: y, width: width, height: height)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                CameraPreview(cameraManager: cameraManager)
                    .ignoresSafeArea()
                
                ForEach(cameraManager.detections) { detection in
                    let box = calculateBox(for: detection, in: geometry)
                    ZStack(alignment: .topLeading) {
                        Rectangle()
                            .stroke(Color.blue, lineWidth: 3)
                            .background(Color.blue.opacity(0.1))
                            .frame(width: box.width, height: box.height)
                        
                        Text("\(detection.label.uppercased()) \(Int(detection.confidence * 100))%")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(4)
                            .background(Color.blue)
                            .cornerRadius(5)
                            .fixedSize(horizontal: true, vertical: false)
                            .shadow(radius: 3)
                            .offset(y: -30)
                            .frame(width: box.width, alignment: .center)
                    }
                    .position(x: box.midX, y: box.midY)
                }
                
                VStack {
                    HStack(alignment: .top) {
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 10) {
                            
                            if let latestSign = cameraManager.recentSigns.first {
                                VStack {
                                    Image(uiImage: latestSign.image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 120, height: 120)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white, lineWidth: 3))
                                        .shadow(radius: 5)
                                    
                                    Text(latestSign.label.uppercased())
                                        .font(.caption)
                                        .bold()
                                        .padding(4)
                                        .background(Color.black.opacity(0.7))
                                        .foregroundColor(.white)
                                        .cornerRadius(4)
                                }
                                .transition(.scale)
                            }
                            
                            if cameraManager.recentSigns.count > 1 {
                                HStack(spacing: 8) {
                                    ForEach(cameraManager.recentSigns.dropFirst()) { sign in
                                        Image(uiImage: sign.image)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 50, height: 50)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.8), lineWidth: 1))
                                            .shadow(radius: 2)
                                    }
                                }
                                .padding(5)
                                .background(Color.black.opacity(0.3))
                                .cornerRadius(10)
                            }
                        }
                        .padding(.top, 50)
                        .padding(.trailing, 20)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        cameraManager.stop()
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                            Text("Finalizar Trayecto")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(10)
                        .padding(.horizontal, 40)
                    }
                    .padding(.bottom, 50)
                }
            }
        }
        .ignoresSafeArea()
        .onAppear { cameraManager.start() }
        .onDisappear { cameraManager.stop() }
        .animation(.spring(), value: cameraManager.recentSigns.count)
        
        .onChange(of: cameraManager.recentSigns.count) { oldValue, newValue in
            if newValue > oldValue, let newSign = cameraManager.recentSigns.first {
                saveDetectionToDatabase(sign: newSign)
            }
        }
    }
    
    private func saveDetectionToDatabase(sign: CapturedSign) {
        guard let user = currentUser else {
            print("Error: No hay usuario logueado")
            return
        }
        
        print("Guardando: \(sign.label) para \(user.name)")
        
        let imageData = sign.image.jpegData(compressionQuality: 0.8)
        
        let newDetection = Detection(
            label: sign.label,
            confidence: 0.90,
            imageData: imageData
        )
        
        newDetection.user = user
        user.detections?.append(newDetection)
        
    }
}
