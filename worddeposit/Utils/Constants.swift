import Foundation
import UIKit

struct Storyboards {
    static let Main = "Main"
    static let Login = "Login"
    static let Home = "Home"
    static let VocabularyResults = "VocabularyResultsTVC"
    static let PracticeReadVC = "PracticeReadVC"
}

struct Controllers {
    static let TrainerWordToTranslate = "TrainerWordToTranslate"
    static let TrainerTranslateToWord = "TrainerTranslateToWord"
    static let Vocabularies = "Vocabularies"
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
    static let dark = #colorLiteral(red: 0.01088568699, green: 0.06228606028, blue: 0.06561407343, alpha: 1)
    static let yellow = #colorLiteral(red: 1, green: 0.7058823529, blue: 0.007843137255, alpha: 1)
    static let silver = #colorLiteral(red: 0.9180576574, green: 0.9599677666, blue: 0.8276135252, alpha: 1)
    static let grey = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
}

struct Fonts {
    static let regular = "DMSans-Regular"
    static let medium = "DMSans-Medium"
    static let bold = "DMSans-Bold"
}

struct Placeholders {
    static let Logo = "logo"
}

struct Images {
    static let trainerWordToTranslate = "trainer-word-to-translate.png"
    static let trainerTranslateToWord = "trainer-translate-to-word.png"
}

struct Keys {
    static let vocabulariesSwitchNotificationKey = "com.maxkalik.worddeposit.vocabulariesSwitchNotificationKey"
    static let currentVocabularyDidUpdateKey = "com.maxkalik.worddeposit.currentVocabularyDidUpdateKey"
}

struct Limits {
    static let vocabularies = 10
    static let words = 300
    static let vocabularyTitle = 26
    static let wordExample = 60
    static let wordTranslation = 60
    static let wordDescription = 80
}
