import SwiftUI

struct DashboardView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                CameraPreview(cameraManager: viewModel.cameraManager)
                    .ignoresSafeArea()
                
                ForEach(viewModel.cameraManager.detections) { detection in
                    let box = viewModel.calculateBox(for: detection, in: geometry)
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
                            if let latestSign = viewModel.cameraManager.recentSigns.first {
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
                            
                            if viewModel.cameraManager.recentSigns.count > 1 {
                                HStack(spacing: 8) {
                                    ForEach(viewModel.cameraManager.recentSigns.dropFirst()) { sign in
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
                        viewModel.stopCamera()
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
        .onAppear { viewModel.startCamera() }
        .onDisappear { viewModel.stopCamera() }
        .animation(.spring(), value: viewModel.cameraManager.recentSigns.count)
    }
}

