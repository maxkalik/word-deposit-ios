import UIKit

protocol PracticeAnswerItemDelegate: PracticeReadVC {
    func practiceAnswerItemBeganLongPressed(with cellFrame: CGRect, and word: String)
    func practiceAnswerItemDidFinishLongPress()
}

class PracticeAnswerItem: UICollectionViewCell {
   
    weak var delegate: PracticeAnswerItemDelegate?
    @IBOutlet weak var deskItemLabel: UILabel!
    
    let generator = UIImpactFeedbackGenerator(style: .heavy)
    var title: String! {
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
        if title.count > 32 {
            if sender.state != .ended {
                UIView.animate(withDuration: 0.3) { [self] in
                    deskItemLabel.alpha = 0.5
                }
                deskItemLabel.alpha = 0.5
                if sender.state == .began {
                    delegate?.practiceAnswerItemBeganLongPressed(with: frame, and: title)
                    generator.impactOccurred()
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
        deskItemLabel.textColor = Colors.blue
        
    }
    
    func configureCell(word: Word, practiceType: PracticeType) {
        switch practiceType {
        case .readWordToTranslate:
            self.title = word.translation
        case .readTranslateToWord:
            self.title = word.example
        }
        
        setupLimit()
    }
    
    private func setupLimit() {
        if title.count > 32 {
            let mutableString = NSMutableAttributedString(string: "\(String(title.prefix(26))) •••")
            mutableString.addAttribute(NSAttributedString.Key.foregroundColor as NSAttributedString.Key, value: Colors.orange, range: NSRange(location:26,length:4))
            deskItemLabel.attributedText = mutableString
        } else {
            deskItemLabel.text = title
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
