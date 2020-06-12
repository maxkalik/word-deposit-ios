import UIKit
import Kingfisher

class WordVC: UIViewController {

    // Outlets
    @IBOutlet weak var wordImageView: UIImageView!
    @IBOutlet weak var wordExample: UILabel!
    @IBOutlet weak var wordTranslation: UILabel!
    
    // Variables
    var word: Word!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wordImageView.layer.cornerRadius = 8
        
        if let url = URL(string: word.imgUrl) {
            wordImageView.kf.indicatorType = .activity
            let options: KingfisherOptionsInfo = [KingfisherOptionsInfoItem.transition(.fade(0.2))]
            wordImageView.kf.setImage(with: url, options: options)
        }
        wordExample.text = word.example
        wordTranslation.text = word.translation
    }
}
