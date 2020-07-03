import UIKit
import Kingfisher

class WordTableViewCell: UITableViewCell {

    // Outlets
    @IBOutlet weak var preview: UIImageView!
    @IBOutlet weak var wordExampleLabel: UILabel!
    @IBOutlet weak var wordTranslationLabel: UILabel!
    
    // Variables
    private var word: Word!
    
    /// If a UITableViewCell object is reusable—that is, it has a reuse identifier—this method is invoked just before the object is returned from the UITableView method
    /// dequeueReusableCell(withIdentifier:) . For performance reasons, you should only reset attributes of the cell that are not related to content
    override func prepareForReuse() {
        super.prepareForReuse()
        preview.image = UIImage(named: "logo")
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
            let placeholder = UIImage(named: "logo")
            preview.kf.setImage(with: url, placeholder: placeholder, options: options)
        }
        
        wordExampleLabel.text = word.example
        wordTranslationLabel.text = word.translation
    }
}
