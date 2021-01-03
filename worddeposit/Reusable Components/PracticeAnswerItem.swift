import UIKit

protocol PracticeAnswerItemDelegate: PracticeReadVC {
    func practiceAnswerItemBeganLongPressed(with cellFrame: CGRect, and word: String)
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
        if word.count > 32 {
            if sender.state != .ended {
                UIView.animate(withDuration: 0.3) { [self] in
                    deskItemLabel.alpha = 0.5
                }
                deskItemLabel.alpha = 0.5
                if sender.state == .began {
                    delegate?.practiceAnswerItemBeganLongPressed(with: frame, and: word)
                }
            } else {
                UIView.animate(withDuration: 0.3) { [self] in
                    deskItemLabel.alpha = 1
                }
                delegate?.practiceAnswerItemDidFinishLongPress()
            }
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
        
        if word.count > 32 {
            deskItemLabel.text = "\(String(word.prefix(26))) ..."
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
