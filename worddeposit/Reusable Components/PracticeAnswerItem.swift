import UIKit

class PracticeAnswerItem: UICollectionViewCell {
   
//    let containerView = UIView()
    @IBOutlet weak var deskItemLabel: UILabel!

    var word: String! {
        didSet {
            deskItemLabel.text = word
            deskItemLabel.font = UIFont(name: Fonts.medium, size: 16)
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
    }
    
    func setupCell() {
        contentView.alpha = 1
        clipsToBounds = true

        deskItemLabel.layer.cornerRadius = Radiuses.large
        deskItemLabel.layer.masksToBounds = true
        deskItemLabel.backgroundColor = Colors.silver

        layer.cornerRadius = Radiuses.large
        backgroundColor = Colors.dark.withAlphaComponent(0.4)
    }
    
    func configureCell(word: String) {
        self.word = word
    }
    
    func correctAnswer() {
        deskItemLabel.backgroundColor = UIColor.green
    }
    
    func wrondAnswer() {
        deskItemLabel.backgroundColor = UIColor.red
    }
    
    func hintAnswer() {
        deskItemLabel.backgroundColor = Colors.yellow
    }
    
    func withoutAnswer() {
        deskItemLabel.backgroundColor = Colors.silver
        contentView.alpha = 0.5
    }
}
