import UIKit

class WordTableViewCell: UITableViewCell {

    // Outlets
    @IBOutlet weak var wordExampleLabel: UILabel!
    @IBOutlet weak var wordTranslationLabel: UILabel!
    
    // Variables
    private var word: Word!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configureCell(word: Word) {
        self.word = word
        
        wordExampleLabel.text = word.example
        wordTranslationLabel.text = word.translation
    }
}
