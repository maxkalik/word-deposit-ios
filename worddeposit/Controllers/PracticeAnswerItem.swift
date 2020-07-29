import UIKit

class PracticeAnswerItem: UICollectionViewCell {
   
    @IBOutlet weak var deskItemLabel: UILabel!

    var word: String! {
        didSet {
            deskItemLabel.text = word
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setupCell()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }
    
    func setupCell() {
        alpha = 1
        contentView.alpha = 1
        backgroundColor = UIColor.white
        layer.cornerRadius = 12
        clipsToBounds = true
    }
    
    func configureCell(word: String) {
        self.word = word
    }
}
