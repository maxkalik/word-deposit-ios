import Foundation
import UIKit

struct Storyboards {
    static let Main = "Main"
    static let Login = "Login"
    static let Home = "Home"
    static let VocabularyResults = "VocabularyResultsTVC"
    static let CheckmarkListTVCResults = "CheckmarkListTVCResults"
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
    static let Profile = "Profile"
}

struct ReusableIdentifiers {
    static let CheckedCell = "CheckedCell"
    static let MessageView = "MessageView"
}

struct Colors {
    static let lightDark = #colorLiteral(red: 0.2002655295, green: 0.2168318651, blue: 0.2408986358, alpha: 1)
    static let dark = #colorLiteral(red: 0.01088568699, green: 0.06228606028, blue: 0.06561407343, alpha: 1)
    static let shadow = #colorLiteral(red: 0.002289562985, green: 0.009225011557, blue: 0.1488199301, alpha: 1)
    static let yellow = #colorLiteral(red: 1, green: 0.7058823529, blue: 0.007843137255, alpha: 1)
    static let orange = #colorLiteral(red: 1, green: 0.4645918398, blue: 0, alpha: 1)
    static let darkOrange = #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1)
    static let silver = #colorLiteral(red: 0.93099447, green: 0.9588879667, blue: 0.9599677666, alpha: 1)
    static let lightGrey = #colorLiteral(red: 0.8789731349, green: 0.8789731349, blue: 0.8789731349, alpha: 1)
    static let grey = #colorLiteral(red: 0.6468691242, green: 0.6480719886, blue: 0.6009513889, alpha: 1)
    static let darkGrey = #colorLiteral(red: 0.457353078, green: 0.457353078, blue: 0.457353078, alpha: 1)
    static let blue = #colorLiteral(red: 0, green: 0.3176470588, blue: 0.6117647059, alpha: 1)
    static let darkBlue = #colorLiteral(red: 0, green: 0.181510762, blue: 0.5298818211, alpha: 1)
    static let green = #colorLiteral(red: 0, green: 0.6042719415, blue: 0, alpha: 1)
}

struct Fonts {
    static let regular = "DMSans-Regular"
    static let medium = "DMSans-Medium"
    static let bold = "DMSans-Bold"
}

struct Icons {
    static let Photo = "photo"
    static let Picture = "picture"
    static let Back = "icon_back"
    static let Arrow = "icon_arrow"
    static let Close = "icon_close"
    static let CheckmarkSmall = "icon_checkmark_small"
    static let CheckboxOn = "icon_checkbox_on"
    static let CheckboxOff = "icon_checkbox_off"
    static let Profile = "icon_profile"
    static let Vocabularies = "icon_vocabularies"
}

struct Images {
    static let trainerWordToTranslate = "trainer-word-to-translate.png"
    static let trainerTranslateToWord = "trainer-translate-to-word.png"
}

struct Keys {
    static let vocabulariesSwitchNotificationKey = "com.maxkalik.worddeposit.vocabulariesSwitchNotificationKey"
    static let vocabulariesSwitchBeganNotificationKey = "com.maxkalik.worddeposit.vocabulariesSwitchBeganNotificationKey"
    static let currentVocabularyDidUpdateKey = "com.maxkalik.worddeposit.currentVocabularyDidUpdateKey"
}

struct Limits {
    static let name = 60
    static let vocabularies = 5
    static let words = 500
    static let vocabularyTitle = 26
    static let wordExample = 60
    static let wordTranslation = 60
    static let wordDescription = 80
}

struct Radiuses {
    static let huge: CGFloat = 20
    static let large: CGFloat = 10
}
