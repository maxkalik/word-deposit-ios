import UIKit

class CheckmarkListTVCell: UITableViewCell {
    
    private var isMarked: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clear
    }
    
    func configure(title: String, isMarked: Bool) {
        textLabel?.text = title
        if isMarked {
            accessoryType = .checkmark
            tintColor = Colors.orange
            textLabel?.font = UIFont(name: Fonts.medium, size: 16)
            textLabel?.textColor = Colors.orange
        } else {
            accessoryType = .none
            textLabel?.font = UIFont(name: Fonts.regular, size: 16)
            textLabel?.textColor = Colors.dark
        }
    }
}
