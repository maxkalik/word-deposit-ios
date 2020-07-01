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
        
        let newCapturePhotoImage = UIImage(systemName: "largecircle.fill.circle")?.withTintColor(UIColor.label) ?? config.icons.capturePhotoImage
        config.icons.capturePhotoImage = newCapturePhotoImage
        return config
    }
}
