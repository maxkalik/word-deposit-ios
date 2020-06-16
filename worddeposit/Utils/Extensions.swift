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
    
    // maybe I do not need this
    func actionsheet(viewController: UIViewController, title: String? = nil, message: String? = nil, actions: [(String, UIAlertAction.Style)], completion: @escaping (_ index: Int) -> Void) {
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        for (index, (title, style)) in actions.enumerated() {
            let alertAction = UIAlertAction(title: title, style: style) { (_) in
                completion(index)
            }
            alertViewController.addAction(alertAction)
        }
        viewController.present(alertViewController, animated: true, completion: nil)
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
}


extension UIImageView {
    func makeRounded() {
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
    }
}

/*
extension Firestore {
    var words: CollectionReference {
//        let userId = UserService.user.id
        // TODO: shoud be rewrited in the singleton
        guard let user = Auth.auth().currentUser else { return nil }
        return Firestore.firestore().collection("users").document(user.uid).collection("words")
    }
}

extension Storage {
    func getWordImageById(_ id: String) -> StorageReference {
        let userId = UserService.user.id
        return Storage.storage().reference().child("/\(userId)/\(id).jpg")
    }
}
*/
