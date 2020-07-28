import UIKit

class PracticeAnswerItem: UICollectionViewCell {
   
    @IBOutlet weak var deskItemLabel: UILabel!

    var word: Word! {
        didSet {
            deskItemLabel.text = word.translation
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.green
        layer.cornerRadius = 12
        clipsToBounds = true
        
    }
    
    func configureCell(word: Word) {
        self.word = word
    }
}
