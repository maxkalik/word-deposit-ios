import UIKit

class PracticeAnswerItem: UICollectionViewCell {
   
    @IBOutlet weak var deskItemButton: PracticeDeskItemButton!

    var word: Word! {
        didSet {
            deskItemButton.setTitle(word.translation, for: .normal)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        print(isSelected, isHighlighted)
        if isSelected {
            deskItemButton.layer.backgroundColor = CGColor(srgbRed: 0, green: 0, blue: 255, alpha: 0)
            deskItemButton.alpha = 1
//            deskItemButton.backgroundColor = .black
            deskItemButton.titleLabel?.textColor = UIColor.white
        } else {
            deskItemButton.alpha = 0.5
//            deskItemButton.isEnabled = false
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(word: Word) {
        self.word = word
    }
}
