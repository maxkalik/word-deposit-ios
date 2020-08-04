import UIKit

class VocabularyDetailsVC: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var languageTextField: UITextField!
    
    
    var vocabularyTitle: String?
    var vocabularyLanguage: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentInsetAdjustmentBehavior = .never
    }
    
    @IBAction func savePressed(_ sender: UIButton) {
        print(vocabularyTitle, vocabularyLanguage)
    }
}
