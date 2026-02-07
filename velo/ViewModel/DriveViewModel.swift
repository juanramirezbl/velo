import Foundation
import Combine

class DriveViewModel: ObservableObject {
    
    let cameraManager = CameraManager()
    
    init() {
        cameraManager.checkPermission()
    }
}
