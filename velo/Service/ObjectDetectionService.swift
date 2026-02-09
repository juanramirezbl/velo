import Foundation
import Vision
import CoreML
import Combine

class ObjectDetectionService: ObservableObject {
    
    
    var detectionsPublisher = PassthroughSubject<[VNRecognizedObjectObservation], Never>()
    
    //vision components
    private var visionModel: VNCoreMLModel?
    private var visionRequest: VNCoreMLRequest?
    
    init() {
        setupModel()
    }
    
    //load model
    private func setupModel() {
        do {
            
            let config = MLModelConfiguration()
            //model best1 trained
            let model = try best1(configuration: config).model
            
            //adapter for vision
            self.visionModel = try VNCoreMLModel(for: model)
            
           
            self.visionRequest = VNCoreMLRequest(model: visionModel!) { [weak self] request, error in
                self?.handleDetections(request: request, error: error)
            }
            
            //crop image
            self.visionRequest?.imageCropAndScaleOption = .scaleFill
            
            print("YOLO works")
            
        } catch {
            print("Yolo doesn't work: \(error)")
        }
    }
    
    //public function
    func detect(pixelBuffer: CVPixelBuffer) {
        guard let request = visionRequest else { return }
        
        //handler
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up)
        
        do {
            try handler.perform([request])
        } catch {
            print("Error: \(error)")
        }
    }
    
    //processing result
    private func handleDetections(request: VNRequest, error: Error?) {
        if let error = error {
            print("Error: \(error)")
            return
        }
        
        // Convert result
        guard let results = request.results as? [VNRecognizedObjectObservation] else { return }
        
        if !results.isEmpty {
            detectionsPublisher.send(results) //sent result 
        }
    }
}
