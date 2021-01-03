import UIKit

protocol PracticeAnswerItemDelegate: PracticeReadVC {
    func practiceAnswerItemBeganLongPressed()
    func practiceAnswerItemDidFinishLongPress()
}

class PracticeAnswerItem: UICollectionViewCell {
   
    weak var delegate: PracticeAnswerItemDelegate?
    @IBOutlet weak var deskItemLabel: UILabel!

    var word: String! {
        didSet {
            deskItemLabel.font = UIFont(name: Fonts.medium, size: 16)
            deskItemLabel.textColor = Colors.dark
            deskItemLabel.highlightedTextColor = Colors.grey
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setupCell()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        longPress.minimumPressDuration = 0.5
        longPress.delaysTouchesBegan = true
        addGestureRecognizer(longPress)
    }
    
    
    @objc private func longPressed(sender: UILongPressGestureRecognizer) {
        if sender.state != .ended {
            if sender.state == .began {
                delegate?.practiceAnswerItemBeganLongPressed()
            }
        } else {
            delegate?.practiceAnswerItemDidFinishLongPress()
        }
    }
    
    func setupCell() {
        contentView.alpha = 1
        clipsToBounds = true

        deskItemLabel.layer.cornerRadius = Radiuses.large
        deskItemLabel.layer.masksToBounds = true
        deskItemLabel.backgroundColor = Colors.silver
        layer.cornerRadius = Radiuses.large
        backgroundColor = Colors.dark.withAlphaComponent(0.3)
        
        
    }
    
    func configureCell(word: String) {
        self.word = word
        
        if word.count > 34 {
            deskItemLabel.text = "\(String(word.prefix(34))).."
        } else {
            deskItemLabel.text = word
        }
    }
    
    func correctAnswer() {
        deskItemLabel.textColor = UIColor.white
        deskItemLabel.backgroundColor = Colors.green
    }
    
    func wrondAnswer() {
        deskItemLabel.textColor = UIColor.white
        deskItemLabel.backgroundColor = UIColor.red
    }
    
    func hintAnswer() {
        deskItemLabel.backgroundColor = Colors.yellow
    }
    
    func withoutAnswer() {
        deskItemLabel.backgroundColor = Colors.silver
        backgroundColor = UIColor.clear
        contentView.alpha = 0.5
    }
}
