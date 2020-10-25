import UIKit

class Checkbox: UIButton {
    
    let checkboxImgOn = UIImage(named: Icons.CheckboxOn)?.withRenderingMode(.alwaysTemplate)
    let checkboxImgOff = UIImage(named: Icons.CheckboxOff)!
    
    var isOn: Bool = false {
        didSet {
            if isOn == true {
                setImage(checkboxImgOn, for: .normal)
                tintColor = Colors.orange
            } else {
                setImage(checkboxImgOff, for: .normal)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addTarget(self, action: #selector(clicked(sender:)), for: .touchUpInside)
        isOn = false
    }
    
    @objc func clicked(sender: UIButton) {
        if sender == self {
            isOn = !isOn
        }
    }
}
