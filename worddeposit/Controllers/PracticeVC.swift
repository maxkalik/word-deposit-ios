import UIKit
import Firebase

class PracticeVC: UIViewController {
    
    // outlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var welcomeLbl: UILabel!
    @IBOutlet weak var wordsLbl: UILabel!
    
    // variables
    var user = User()
    var words = [Word]()
    var auth = Auth.auth()
    var db = Firestore.firestore()
    var userListener: ListenerRegistration? = nil
    var wordsListener: ListenerRegistration? = nil

    override func viewDidAppear(_ animated: Bool) {
        getCurrentUser()
    }
    
    override func viewDidLoad() {
        welcomeLbl.isHidden = true
        wordsLbl.isHidden = true
        activityIndicator.startAnimating()
        print(words)
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
            self.welcomeLbl.isHidden = false
        })
        
        fetchWords(from: userRef)
    }
    
    func fetchWords(from: DocumentReference) {
        let wordsRef = from.collection("words")
        wordsListener = wordsRef.addSnapshotListener({ (snapshot, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            self.words.removeAll()
            guard let documents = snapshot?.documents else { return }
            for document in documents {
                let data = document.data()
                let word = Word.init(data: data)
                self.words.append(word)
            }
            self.wordsLbl.text = String(self.words.count)
            self.wordsLbl.isHidden = false
        })
    }
}
