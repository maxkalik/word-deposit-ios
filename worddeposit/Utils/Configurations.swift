import Foundation
import YPImagePicker

class YPImagePickerConfig {
    
    var config = YPImagePickerConfiguration()
    
    func defaultConfig() -> YPImagePickerConfiguration {
        config.onlySquareImagesFromCamera = true
        config.shouldSaveNewPicturesToAlbum = true
        config.screens = [.library, .photo]
        config.albumName = "WordDeposit"
        config.showsPhotoFilters = false
        config.hidesStatusBar = false
        
        let newCapturePhotoImage = UIImage.circle(diameter: 80.00, color: Colors.orange)
        config.icons.capturePhotoImage = newCapturePhotoImage
        return config
    }
}
