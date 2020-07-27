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
            
//            print("is selected")
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            setNeedsLayout()
            layoutIfNeeded()
//            print("is highlighter")
//            print(isSelected)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        print(isSelected, isHighlighted)
        if isHighlighted {
            deskItemButton.backgroundColor = .blue
        } else {
            deskItemButton.alpha = 0.2
            deskItemButton.isUserInteractionEnabled = false
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    func configureCell(word: Word) {
        self.word = word
    }
}
