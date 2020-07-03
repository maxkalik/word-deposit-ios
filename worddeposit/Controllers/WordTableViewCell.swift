import UIKit
import Kingfisher

class WordTableViewCell: UITableViewCell {

    // Outlets
    @IBOutlet weak var preview: UIImageView!
    @IBOutlet weak var wordExampleLabel: UILabel!
    @IBOutlet weak var wordTranslationLabel: UILabel!
    
    // Variables
    private var word: Word!
    
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
        print("vocabulary cell", word)
        
        if let url = URL(string: word.imgUrl) {
            preview.kf.indicatorType = .activity
            let options: KingfisherOptionsInfo = [KingfisherOptionsInfoItem.transition(.fade(0.2))]
            let placeholder = UIImage(named: "logo")
            print(url)
            preview.kf.setImage(with: url, placeholder: placeholder, options: options)
            
            let cache = ImageCache.default
            let cached = cache.isCached(forKey: word.imgUrl)
            print("---------- image is cashed: ", cached)
            cache.clearMemoryCache()
            
        }
        
        wordExampleLabel.text = word.example
        wordTranslationLabel.text = word.translation
    }
}
