import UIKit
import Kingfisher

protocol VocabularyTVCellDelegate: VocabularyTVC {
    func vocabularyTVCellBeganLongPressed(with cellFrame: CGRect, and word: Word)
    func vocabularyTVCellDidFinishLognPress()
}

class VocabularyTVCell: UITableViewCell {

    let generator = UIImpactFeedbackGenerator(style: .heavy)
    
    weak var delegate: VocabularyTVCellDelegate?
    // Outlets
    @IBOutlet weak var preview: UIImageView!
    @IBOutlet weak var wordExampleLabel: UILabel! {
        didSet {
            wordExampleLabel.font = UIFont(name: Fonts.bold, size: 16)
            guard let text = wordExampleLabel.text else { return }
            wordExampleLabel.addCharactersSpacing(spacing: -0.4, text: text)
        }
    }
    @IBOutlet weak var wordTranslationLabel: UILabel! {
        didSet {
            wordTranslationLabel.font = UIFont(name: Fonts.medium, size: 16)
            guard let text = wordTranslationLabel.text else { return }
            wordTranslationLabel.addCharactersSpacing(spacing: -0.4, text: text)
        }
    }
    
    // Variables
    private var word: Word!
    
    /// If a UITableViewCell object is reusable—that is, it has a reuse identifier—this method is invoked just before the object is returned from the UITableView method
    /// dequeueReusableCell(withIdentifier:) . For performance reasons, you should only reset attributes of the cell that are not related to content
    override func prepareForReuse() {
        super.prepareForReuse()
        preview.image = .none
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        preview.makeRounded()
        wordTranslationLabel.textColor = Colors.darkGrey
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        // longPress.min
        longPress.minimumPressDuration = 0.5
        longPress.delaysTouchesBegan = true
        addGestureRecognizer(longPress)
    }
    
    @objc private func longPressed(sender: UILongPressGestureRecognizer) {
        if sender.state != .ended {
            if sender.state == .began {
                delegate?.vocabularyTVCellBeganLongPressed(with: frame, and: word)
                generator.impactOccurred()
            }
        } else {
            delegate?.vocabularyTVCellDidFinishLognPress()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(word: Word) {
        self.word = word
        
        if let url = URL(string: word.imgUrl) {
            preview.kf.indicatorType = .activity
            let options: KingfisherOptionsInfo = [KingfisherOptionsInfoItem.transition(.fade(0.2))]
            preview.kf.setImage(with: url, options: options)
        } else {
            preview.image = .none
        }
        
        wordExampleLabel.text = word.example
        wordTranslationLabel.text = word.translation
    }
}
