import UIKit

class PracticeAnswerItem: UICollectionViewCell {
   
//    let containerView = UIView()
    @IBOutlet weak var deskItemLabel: UILabel!

    var word: String! {
        didSet {
            deskItemLabel.text = word
            deskItemLabel.font = UIFont(name: Fonts.bold, size: 16)
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
        alpha = 1
        contentView.alpha = 1
        backgroundColor = Colors.silver
        layer.cornerRadius = Radiuses.large
        clipsToBounds = true
//        containerView.backgroundColor = Colors.dark
//
//        addSubview(containerView)
//
//        // add constraints
//        containerView.translatesAutoresizingMaskIntoConstraints = false
//
//        // pin the containerView to the edges to the view
//        containerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
//        containerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
//        containerView.heightAnchor.constraint(equalToConstant: 2).isActive = true
//        containerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    func configureCell(word: String) {
        self.word = word
    }
    
    func correctAnswer() {
        backgroundColor = UIColor.green
    }
    
    func wrondAnswer() {
        backgroundColor = UIColor.red
    }
    
    func hintAnswer() {
        backgroundColor = Colors.yellow
    }
    
    func withoutAnswer() {
        backgroundColor = Colors.silver
        alpha = 0.5
        contentView.alpha = 0.5
    }
}
