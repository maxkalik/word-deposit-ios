import UIKit
import Firebase

class PracticeVC: UIViewController {
    
    // outlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var welcomeLbl: UILabel!
    
    // variables
    var user = User()
    var words = [Word]()
    var auth = Auth.auth()
    var db = Firestore.firestore()
    var userListener: ListenerRegistration? = nil
    var wordsListener: ListenerRegistration? = nil

    override func viewWillAppear(_ animated: Bool) {
        getCurrentUser()
    }
    
    override func viewDidLoad() {
        activityIndicator.startAnimating()
        print("PRACTICE WORDS", words)
    }
    
    func getCurrentUser() {
        guard let authUser = auth.currentUser else { return }
        let userRef = db.collection("users").document(authUser.uid)
        
        userListener = userRef.addSnapshotListener({ (docSnapshot, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            guard let data = docSnapshot?.data() else { return }
            self.user = User.init(data: data)
            self.activityIndicator.stopAnimating()
            self.welcomeLbl.text = self.user.email
        })
        
        let wordsRef = userRef.collection("words")
        wordsListener = wordsRef.addSnapshotListener({ (snapshot, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            snapshot?.documents.forEach({ (documentSnap) in
                let word = Word.init(data: documentSnap.data())
                self.words.append(word)
            })
        })
    }
}
