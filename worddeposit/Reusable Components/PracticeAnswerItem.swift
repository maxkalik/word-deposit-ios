import UIKit

class PracticeAnswerItem: UICollectionViewCell {
   
//    let containerView = UIView()
    @IBOutlet weak var deskItemLabel: UILabel!

    var word: String! {
        didSet {
            deskItemLabel.text = word
            deskItemLabel.font = UIFont(name: Fonts.medium, size: 16)
            deskItemLabel.textColor = Colors.dark
            deskItemLabel.highlightedTextColor = Colors.grey
            
            // deskItemLabel.numberOfLines = 0
            // deskItemLabel.lineBreakMode = .byWordWrapping
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setupCell()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
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
