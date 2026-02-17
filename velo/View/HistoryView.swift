import SwiftUI

struct HistoryView: View {
    @ObservedObject var viewModel: HistoryViewModel
    
    var body: some View {
        List {
            if viewModel.detections.isEmpty {
                ContentUnavailableView(
                    "Sin detecciones",
                    systemImage: "eye.slash",
                    description: Text("No se han detectado señales para este coche.")
                )
            } else {
                ForEach(viewModel.detections) { detection in
                    HStack(spacing: 15) {
                        if let data = detection.imageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 70, height: 70)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                        } else {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 70, height: 70)
                                .cornerRadius(10)
                                .overlay(Image(systemName: "photo").foregroundColor(.gray))
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text(detection.label.uppercased())
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(detection.timestamp.formatted(date: .abbreviated, time: .standard))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("Confianza: \(Int(detection.confidence * 100))%")
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.green.opacity(0.2))
                                .foregroundColor(.green)
                                .cornerRadius(4)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .onDelete(perform: viewModel.deleteDetection)
            }
        }
        .navigationTitle("Detecciones")
        .onAppear { viewModel.loadDetections() }
    }
}

