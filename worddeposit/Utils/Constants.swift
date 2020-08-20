import Foundation
import UIKit

struct Storyboards {
    static let Login = "Login"
    static let Home = "Home"
    static let VocabularyResults = "VocabularyResultsTVC"
    static let PracticeReadVC = "PracticeReadVC"
}

struct Controllers {
    static let TrainerWordToTranslate = "TrainerWordToTranslate"
    static let TrainerTranslateToWord = "TrainerTranslateToWord"
}

struct XIBs {
    static let VocabulariesTVCell = "VocabulariesTVCell"
    static let VocabularyTVCell = "VocabularyTVCell"
    static let VocabularyCardCVCell = "VocabularyCardCVCell"
    static let PracticeCVCell = "PracticeCVCell"
    static let PracticeAnswerItem = "PracticeAnswerItem"
    static let MessageCVCell = "MessageCVCell"
}

struct Segues {
    static let Vocabularies = "Vocabularies"
    static let VocabularyDetails = "VocabularyDetails"
    static let UserInfo = "UserInfo"
    static let NativeLanguage = "NativeLanguage"
    static let AccountType = "AccountType"
    static let Appearance = "Appearance"
    static let PrivacyAndSecurity = "PrivacyAndSecurity"
    static let FAQ = "FAQ"
    static let About = "About"
    static let PracticeRead = "PracticeRead"
}

struct ReusableIdentifiers {
    static let CheckedCell = "CheckedCell"
    static let MessageView = "MessageView"
}

struct Colors {
    static let black = UIColor.black.cgColor
}

struct Placeholders {
    static let Logo = "logo"
}

struct Images {
    static let trainerWordToTranslate = "trainer-word-to-translate.png"
    static let trainerTranslateToWord = "trainer-translate-to-word.png"
}
