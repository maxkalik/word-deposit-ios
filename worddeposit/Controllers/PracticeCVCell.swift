import UIKit
import Kingfisher

class PracticeCVCell: UICollectionViewCell {

    @IBOutlet weak var imageCover: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 10
        self.setNeedsUpdateConstraints()
        self.updateFocusIfNeeded()
        self.layoutIfNeeded()
    }
    
    func configureCell(cover: String, title: String) {
        imageCover.image = UIImage(named: cover)
        titleLabel.text = title
    }
    
    
}
