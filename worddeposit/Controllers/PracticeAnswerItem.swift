import UIKit

class PracticeAnswerItem: UICollectionViewCell {

    @IBOutlet weak var wordButton: UIButton!
    
    var word: Word! {
        didSet {
            wordButton.setTitle(word.translation, for: .normal)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(word: Word) {
        self.word = word
    }
    
    @IBAction func wordLabelTouched(_ sender: UIButton) {
        print("tapped")
    }
    
}
