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
    static let dark = #colorLiteral(red: 0.01088568699, green: 0.06228606028, blue: 0.06561407343, alpha: 1)
    static let yellow = #colorLiteral(red: 1, green: 0.7058823529, blue: 0.007843137255, alpha: 1)
    static let orange = #colorLiteral(red: 1, green: 0.4645918398, blue: 0, alpha: 1)
    static let silver = #colorLiteral(red: 0.9314891436, green: 0.9599677666, blue: 0.8717267808, alpha: 1)
    static let grey = #colorLiteral(red: 0.6468691242, green: 0.6480719886, blue: 0.6009513889, alpha: 1)
    static let blue = #colorLiteral(red: 0, green: 0.3176470588, blue: 0.6117647059, alpha: 1)
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
