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
    
    // MARK: - variables
    
    var result: Result? {
        didSet {
            isVocabularyEmpty = result?.wordsAmount == 0
            setupModal()
        }
    }
    
    var isVocabularyEmpty = false
    private var titleBtn: String = "Finish"
    weak var delegate: SuccessMessageVCDelegate?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isModalInPresentation = true
        
        answersStackView.layer.cornerRadius = Radiuses.large
        answersStackView.clipsToBounds = true
        
        separatorView.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        
        let titleText = printTitle(with: result?.answerCorrect ?? 0, and: result?.answerWrong ?? 0)
        let descriptionText = isVocabularyEmpty ? "You trained all (\(String(result?.wordsAmount ?? 0))) words" : "You trained \(String(result?.wordsAmount ?? 0)) words"
        
        contentView.layer.backgroundColor = Colors.yellow.cgColor
        
        titleLabel.font = UIFont(name: Fonts.bold, size: 28)
        titleLabel.addCharactersSpacing(spacing: -0.8, text: titleText)
        
        descriptionLabel.font = UIFont(name: Fonts.medium, size: 18)
        descriptionLabel.addCharactersSpacing(spacing: -0.6, text: descriptionText)
        
        let answersFont = UIFont(name: Fonts.bold, size: 18)
        
        correctWordsLabel.font = answersFont
        wrongWordsLabel.font = answersFont
        
        correctWordsLabel.textColor = Colors.green
        wrongWordsLabel.textColor = #colorLiteral(red: 0.7483542195, green: 0.1328815494, blue: 0, alpha: 1)
        
        titleLabel.text = titleText
        
        descriptionLabel.text = descriptionText
        correctWordsLabel.text = "Correct: \(String(result?.answerCorrect ?? 0))"
        wrongWordsLabel.text = "Wrong: \(String(result?.answerWrong ?? 0))"
        
        button.setTitle(titleBtn, for: .normal)
    }
    
    func setupModal() {
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .popover
    }
    
    private func printTitle(with rightAnswers: Int, and wrongAnswers: Int) -> String {
        // get precentage
        let answersSum = rightAnswers + wrongAnswers
        let precentageOfCorrectAnswers = (rightAnswers * 100) / answersSum
        
        guard let result = self.result else { return "" }
        
        if result.wordsAmount < 5 {
            imageView.image = UIImage(named: "walking")
            return "You could practice more words"
        } else if result.wordsAmount >= 5 && result.wordsAmount < 10 {
            imageView.image = UIImage(named: "standing")
            if isVocabularyEmpty { return "Better add more words" }
            return "Already finished?"
        } else {
            if rightAnswers > wrongAnswers {
                if precentageOfCorrectAnswers > 70 {
                    imageView.image = UIImage(named: "rocker")
                    return "Perfect!"
                } else if precentageOfCorrectAnswers > 90 {
                    imageView.image = UIImage(named: "skater")
                    return "Excelent!"
                } else {
                    imageView.image = UIImage(named: "social")
                    return "Great!"
                }
            } else {
                if precentageOfCorrectAnswers < 30 {
                    imageView.image = UIImage(named: "sitting")
                    return "It's not your the best result."
                } else if precentageOfCorrectAnswers < 10 {
                    imageView.image = UIImage(named: "standing")
                    return "You can do better!"
                } else {
                    imageView.image = UIImage(named: "walking")
                    return "Mistakes are ok."
                }
            }
        }
    }
        
    @IBAction func buttonTap(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        delegate?.onSuccessMessageButtonTap()
    }
}
