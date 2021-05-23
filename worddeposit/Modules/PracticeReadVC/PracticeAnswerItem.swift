import UIKit

protocol PracticeAnswerItemDelegate: PracticeReadVC {
    func practiceAnswerItemBeganLongPressed(with cellFrame: CGRect, and word: String)
    func practiceAnswerItemDidFinishLongPress()
}

enum Answer {
    case correct
    case wrong
    case withoutAnswer
    case noneAnswer
}

class PracticeAnswerItem: UICollectionViewCell {
   
    weak var delegate: PracticeAnswerItemDelegate?
    @IBOutlet weak var deskItemLabel: UILabel!
    
    let generator = UIImpactFeedbackGenerator(style: .heavy)
    private var title: String?
    private var answer: Answer?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setupCell()
        self.answer = .noneAnswer
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
        self.answer = .noneAnswer
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        longPress.minimumPressDuration = 0.5
        longPress.delaysTouchesBegan = true
        addGestureRecognizer(longPress)
    }
    
    func setupCell() {
        clipsToBounds = true
        layer.cornerRadius = Radiuses.large
        deskItemLabel.layer.cornerRadius = Radiuses.large
        deskItemLabel.layer.masksToBounds = true
        deskItemLabel.font = UIFont(name: Fonts.medium, size: 16)
        
    }
    
    @objc private func longPressed(sender: UILongPressGestureRecognizer) {
        if let title = self.title, title.count > 32 {
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
    
    private var practiceType: PracticeType?
    
    func configureCell(word: Word, practiceType: PracticeType, answer: Answer?) {
        self.practiceType = practiceType
        self.answer = answer
        
        setupPracticeType(for: word)
        setupAnswer()
        setupLimit()
    }
    
    private func setupPracticeType(for word: Word) {
        guard let type = self.practiceType else { return }
        switch type {
        case .readWordToTranslate:
            self.title = word.translation
            break
        case .readTranslateToWord:
            self.title = word.example
            break
        }
    }
    
    private func setupAnswer() {
        switch self.answer {
        case .correct:
            correctAnswer()
        case .wrong:
            wrongAnswer()
        case .withoutAnswer:
            withoutAnswer()
        default:
            defaultAnswer()
        }
    }
    
    private func setupLimit() {
        if let title = self.title, title.count > 32 {
            let mutableString = NSMutableAttributedString(string: "\(String(title.prefix(26))) •••")
            mutableString.addAttribute(NSAttributedString.Key.foregroundColor as NSAttributedString.Key, value: Colors.orange, range: NSRange(location:26,length:4))
            deskItemLabel.attributedText = mutableString
        } else {
            deskItemLabel.text = title
        }
    }
    
    func defaultAnswer() {
        deskItemLabel.textColor = Colors.blue
        deskItemLabel.backgroundColor = UIColor.white
        backgroundColor = Colors.dark.withAlphaComponent(0.3)
        contentView.alpha = 1
    }
    
    func correctAnswer() {
        deskItemLabel.textColor = UIColor.white
        deskItemLabel.backgroundColor = Colors.green
        backgroundColor = Colors.dark.withAlphaComponent(0.3)
        contentView.alpha = 1
    }
    
    func wrongAnswer() {
        deskItemLabel.textColor = UIColor.white
        deskItemLabel.backgroundColor = UIColor.red
        backgroundColor = Colors.dark.withAlphaComponent(0.3)
        contentView.alpha = 1
    }
    
    func withoutAnswer() {
        deskItemLabel.textColor = PracticeReadHelper.shared.getBasicColor(type: self.practiceType)
        deskItemLabel.backgroundColor = Colors.silver
        backgroundColor = UIColor.clear
        contentView.alpha = 0.5
    }
    
    func hintAnswer() {
        deskItemLabel.backgroundColor = Colors.yellow
    }
}
