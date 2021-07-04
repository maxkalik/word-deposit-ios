import UIKit

protocol SuccessMessageVCDelegate: AnyObject {
    func onSuccessMessageButtonTap()
}

class SuccessMessageVC: UIViewController {
    @IBOutlet weak var contentView: RoundedView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var correctWordsLabel: UILabel!
    @IBOutlet weak var wrongWordsLabel: UILabel!
    @IBOutlet weak var button: PrimaryButton!
    @IBOutlet weak var answersStackView: UIStackView!
    @IBOutlet weak var separatorView: UIView!
    
    var viewModel: SuccessMessageViewModel?
    weak var delegate: SuccessMessageVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        setupBackground()
        setupContent()
    }
    
    func setupContent() {
        setupTitleLabel()
        setupDescriptionLabel()
        setupWordsAmountLabels()
        setupButton()
    }
    
    private func configure() {
        guard let model = self.viewModel else { return }
        isModalInPresentation = model.isModalDismissableOnSwap
    }
    
    private func setupBackground() {
        answersStackView.layer.cornerRadius = Radiuses.large
        answersStackView.clipsToBounds = true
        separatorView.backgroundColor = Colors.grey
        contentView.layer.backgroundColor = Colors.yellow.cgColor
    }
    
    private func setupTitleLabel() {
        guard let text = self.viewModel?.title else { return }
        titleLabel.text = text
        titleLabel.font = UIFont(name: Fonts.bold, size: 28)
        titleLabel.addCharactersSpacing(spacing: -0.8, text: text)
    }
    
    private func setupDescriptionLabel() {
        guard let text = self.viewModel?.description else { return }
        descriptionLabel.text = text
        descriptionLabel.font = UIFont(name: Fonts.medium, size: 18)
        descriptionLabel.addCharactersSpacing(spacing: -0.6, text: text)
    }
    
    private func setupWordsAmountLabels() {
        let font = UIFont(name: Fonts.bold, size: 18)
        correctWordsLabel.font = font
        wrongWordsLabel.font = font

        correctWordsLabel.textColor = Colors.green
        wrongWordsLabel.textColor = Colors.red
        
        guard let correctWordsText = self.viewModel?.correctWords,
              let wrongWordsText = self.viewModel?.wrongWords else { return }
        correctWordsLabel.text = correctWordsText
        wrongWordsLabel.text = wrongWordsText
    }
    
    private func setupButton() {
        button.setTitle("Finish", for: .normal)
    }
    
    @IBAction func buttonTap(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        delegate?.onSuccessMessageButtonTap()
    }
}
