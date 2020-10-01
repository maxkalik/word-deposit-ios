import UIKit
import Kingfisher

class PracticeCVCell: UICollectionViewCell {

    @IBOutlet weak var imageCover: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = Radiuses.large
        titleLabel.font = UIFont(name: Fonts.bold, size: 18)
    }
    
    func configureCell(cover: String, title: String) {
        imageCover.image = UIImage(named: cover)
        titleLabel.text = title
    }
    
    
}
