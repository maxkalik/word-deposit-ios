import UIKit
import Kingfisher

class VocabularyTVCell: UITableViewCell {

    // Outlets
    @IBOutlet weak var preview: UIImageView!
    @IBOutlet weak var wordExampleLabel: UILabel! {
        didSet {
            wordExampleLabel.font = UIFont(name: Fonts.bold, size: 16)
            guard let text = wordExampleLabel.text else { return }
            wordExampleLabel.addCharactersSpacing(spacing: -0.6, text: text)
        }
    }
    @IBOutlet weak var wordTranslationLabel: UILabel! {
        didSet {
            wordTranslationLabel.font = UIFont(name: Fonts.medium, size: 16)
            guard let text = wordTranslationLabel.text else { return }
            wordTranslationLabel.addCharactersSpacing(spacing: -0.6, text: text)
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
        wordTranslationLabel.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
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
        }
        
        wordExampleLabel.text = word.example
        wordTranslationLabel.text = word.translation
    }
}
