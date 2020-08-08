import Foundation
import Firebase
import FirebaseStorage

extension String {
    var isNotEmpty: Bool {
        return !isEmpty
    }
}

extension UIViewController {
    func simpleAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension UIImage {
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvas = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        let format = imageRendererFormat
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
    
    class func circle(diameter: CGFloat, color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: diameter, height: diameter), false, 0)
        // Return the current graphics context (width, height, bpc, bpp, row bytes -> from UIGraphicsBeginImageContextWithOptions()
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.saveGState()
        
        // create a rect where we put an image
        let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        ctx.setFillColor(color.cgColor)
        ctx.fillEllipse(in: rect)
        
        // Sets the current graphics state to the state most recently saved
        // Core Graphics removes the graphics state at the top of the stack so that the most recently saved state becomes the current graphics state
        ctx.restoreGState()
        // Returns an image based on the contents of the current bitmap-based graphics context.
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return img
    }
}


extension UIImageView {
    func makeRounded() {
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
    }
}

/*
extension Firestore {
    var categories: Query {
        return collection("categories").order(by: "timeStamp", descending: true)
    }
    func products(categoryId: String) -> Query {
        return collection("products").whereField("category", isEqualTo: categoryId).order(by: "timeStamp", descending: true)
    }
}
*/
