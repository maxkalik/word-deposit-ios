import Foundation
import YPImagePicker

class YPImagePickerConfig {
    
    // Set the default configuration for all pickers
//    YPImagePickerConfiguration.shared = config
    
    var config = YPImagePickerConfiguration()
    
    func defaultConfig() -> YPImagePickerConfiguration {
        config.onlySquareImagesFromCamera = true
        config.shouldSaveNewPicturesToAlbum = true
        config.screens = [.library, .photo]
        config.albumName = "WordDeposit"
        config.showsPhotoFilters = false
        
        let newCapturePhotoImage = UIImage.circle(diameter: 80.00, color: #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1))
        config.icons.capturePhotoImage = newCapturePhotoImage
        return config
    }
}