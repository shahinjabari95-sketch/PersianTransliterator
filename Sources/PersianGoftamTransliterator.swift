//
//  PersianGoftamTransliterator.swift
//  goftam
//
//  Created by Brett Gutstein on 5/6/20.
//  Copyright © 2020 Brett Gutstein. All rights reserved.
//

// BFG: investigate better ways to generate candidates
// (store dictionary in trie, prune using dictionary while
// generating; map roman characters to the chosen
// transliteration rather than counting the times a
// transliterated word is selected)
class PersianGoftamTransliterator: GoftamTransliterator {

    private let _punctuationMap: Dictionary<Character, Character> = [
        "," : "،",
        ";" : "؛",
        "?" : "؟",
        "<" : "»",
        ">" : "«"
    ]

    private let _digitMap: Dictionary<Character, Character> = [
        "0" : "۰",
        "1" : "۱",
        "2" : "۲",
        "3" : "۳",
        "4" : "۴",
        "5" : "۵",
        "6" : "۶",
        "7" : "۷",
        "8" : "۸",
        "9" : "۹"
    ]

    private let _recognizedCharacters: Set<Character> =
        ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
         "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
         "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
         "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
         "'"]

    // rule map inputs should only contain recognized characters;
    // priority order of rules for the same input characters affects transliteration
    private let _rules: [GoftamTransliterationRule] = [
        // BFG: reduce rule list size by eliminating redundancy? e.g. kh and x or u and oo

        GoftamTransliterationRule([.beginning], "aa", "آ"),
        GoftamTransliterationRule([.middle, .end], "aa", "ا"),
        GoftamTransliterationRule([.beginning, .middle, .end], "ch", "چ"),
        GoftamTransliterationRule([.beginning, .middle, .end], "kh", "خ"),
        GoftamTransliterationRule([.beginning, .middle, .end], "zh", "ژ"),
        GoftamTransliterationRule([.beginning, .middle, .end], "sh", "ش"),
        GoftamTransliterationRule([.beginning, .middle, .end], "gh", "ق"),
        GoftamTransliterationRule([.beginning, .middle, .end], "gh", "غ"),
        GoftamTransliterationRule([.beginning], "oo", "او"),
        GoftamTransliterationRule([.middle, .end], "oo", "و"),
        GoftamTransliterationRule([.end], "an", "اً"),

        GoftamTransliterationRule([.beginning], "a", "ا"),
        GoftamTransliterationRule([.middle, .end], "a", ""),
        GoftamTransliterationRule([.beginning], "a", "آ"),
        GoftamTransliterationRule([.middle, .end], "a", "ا"),
        GoftamTransliterationRule([.end], "a", "ه"),
        GoftamTransliterationRule([.beginning, .middle, .end], "a", "ع"), // is .end useful?

        GoftamTransliterationRule([.beginning, .middle, .end], "b", "ب"),
        GoftamTransliterationRule([.beginning, .middle, .end], "c", "ک"),
        GoftamTransliterationRule([.beginning, .middle, .end], "d", "د"),

        GoftamTransliterationRule([.beginning], "e", "ا"),
        GoftamTransliterationRule([.middle], "e", ""), // adding .end to support ezafe makes results worse
        GoftamTransliterationRule([.end], "e", "ه"),
        GoftamTransliterationRule([.beginning, .middle, .end], "e", "ع"), // is .end useful?

        GoftamTransliterationRule([.beginning, .middle, .end], "f", "ف"),
        GoftamTransliterationRule([.beginning, .middle, .end], "g", "گ"),

        GoftamTransliterationRule([.beginning, .middle, .end], "h", "ه"),
        GoftamTransliterationRule([.beginning, .middle, .end], "h", "ح"),

        GoftamTransliterationRule([.beginning], "i", "ای"),
        GoftamTransliterationRule([.middle, .end], "i", "ی"),
        GoftamTransliterationRule([.beginning, .middle, .end], "j", "ج"),
        GoftamTransliterationRule([.beginning, .middle, .end], "k", "ک"),
        GoftamTransliterationRule([.beginning, .middle, .end], "l", "ل"),
        GoftamTransliterationRule([.beginning, .middle, .end], "m", "م"),
        GoftamTransliterationRule([.beginning, .middle, .end], "n", "ن"),

        GoftamTransliterationRule([.beginning], "o", "ا"),
        GoftamTransliterationRule([.middle, .end], "o", ""),
        GoftamTransliterationRule([.beginning, .middle, .end], "o", "و"),
        GoftamTransliterationRule([.end], "o", "ه"),
        GoftamTransliterationRule([.beginning, .middle, .end], "o", "ع"), // is .end useful?

        GoftamTransliterationRule([.beginning, .middle, .end], "p", "پ"),

        GoftamTransliterationRule([.beginning, .middle, .end], "q", "ق"),
        GoftamTransliterationRule([.beginning, .middle, .end], "q", "غ"),

        GoftamTransliterationRule([.beginning, .middle, .end], "r", "ر"),

        GoftamTransliterationRule([.beginning, .middle, .end], "s", "س"),
        GoftamTransliterationRule([.beginning, .middle, .end], "s", "ص"),
        GoftamTransliterationRule([.beginning, .middle, .end], "s", "ث"),

        GoftamTransliterationRule([.beginning, .middle, .end], "t", "ت"),
        GoftamTransliterationRule([.beginning, .middle, .end], "t", "ط"),

        GoftamTransliterationRule([.beginning], "u", "او"),
        GoftamTransliterationRule([.middle, .end], "u", "و"),
        GoftamTransliterationRule([.beginning, .middle, .end], "v", "و"),
        GoftamTransliterationRule([.beginning, .middle, .end], "w", "و"),
        GoftamTransliterationRule([.beginning, .middle, .end], "x", "خ"),
        GoftamTransliterationRule([.beginning, .middle, .end], "y", "ی"),

        GoftamTransliterationRule([.beginning, .middle, .end], "z", "ز"),
        GoftamTransliterationRule([.beginning, .middle, .end], "z", "ذ"),
        GoftamTransliterationRule([.beginning, .middle, .end], "z", "ظ"),
        GoftamTransliterationRule([.beginning, .middle, .end], "z", "ض"),

        GoftamTransliterationRule([.beginning, .middle, .end], "'", "ع"),

        GoftamTransliterationRule([.beginning, .middle, .end], "khaa", "خوا"),
        GoftamTransliterationRule([.beginning, .middle, .end], "kha", "خوا"),
        GoftamTransliterationRule([.beginning, .middle, .end], "xaa", "خوا"),
        GoftamTransliterationRule([.beginning, .middle, .end], "xa", "خوا"),
        
        GoftamTransliterationRule([.end], "ye", "ی"),
        // dictionary words don't have hamze
        GoftamTransliterationRule([.end], "eye", "هٔ"),
        GoftamTransliterationRule([.end], "aye", "هٔ"), // is this useful?
        GoftamTransliterationRule([.end], "oye", "هٔ"), // is this useful?

        GoftamTransliterationRule([.end], "ei", "ه‌ای"),
        GoftamTransliterationRule([.end], "ii", "ی‌ای"),
        GoftamTransliterationRule([.end], "ai", "ه‌ای"), // is this useful?
        GoftamTransliterationRule([.end], "oi", "ه‌ای"), // is this useful?
        // dictionary words don't have hamze
        GoftamTransliterationRule([.end], "ai", "ائی"),
        GoftamTransliterationRule([.end], "aai", "ائی"),
        GoftamTransliterationRule([.end], "ui", "وئی"),
        GoftamTransliterationRule([.end], "ooi", "وئی"),

        GoftamTransliterationRule([.end], "eha", "ه‌ها"),
        GoftamTransliterationRule([.end], "ehaa", "ه‌ها"),
        GoftamTransliterationRule([.end], "aha", "ه‌ها"), // is this useful?
        GoftamTransliterationRule([.end], "ahaa", "ه‌ها"), // is this useful?
        GoftamTransliterationRule([.end], "oha", "ه‌ها"), // is this useful?
        GoftamTransliterationRule([.end], "ohaa", "ه‌ها"), // is this useful?

    ]

    private let _transliterator: GoftamTransliterationEngine

    //input mode name (from ComponentInputModeDict in Info.plist)
    static var transliteratorName: String = "goftampersian"

    init() {
        self._transliterator = GoftamTransliterationEngine(self._rules)
    }

    func recognizedCharacters() -> Set<Character> {
        return self._recognizedCharacters
    }

    func punctuationMap() -> Dictionary<Character, Character> {
        return self._punctuationMap
    }

    func digitMap() -> Dictionary<Character, Character> {
        return self._digitMap
    }

    func generateCandidates(_ input: String) -> [String] {
    let normalized = input
        .lowercased()
        .replacingOccurrences(of: "ā", with: "aa")
        .replacingOccurrences(of: "ī", with: "i")
        .replacingOccurrences(of: "ū", with: "u")

    // Common Persian words and colloquial forms.
    // These are local and require no network connection.
    let common: [String: [String]] = [
        "salam": ["سلام"],
        "salaam": ["سلام"],

        "chetori": ["چطوری"],
        "chetoori": ["چطوری"],
        "chetory": ["چطوری"],

        "khubi": ["خوبی"],
        "khoobi": ["خوبی"],
        "khuby": ["خوبی"],

        "khob": ["خوب"],
        "khoob": ["خوب"],

        "merci": ["مرسی"],
        "mersi": ["مرسی"],

        "mamnoon": ["ممنون"],
        "mamnon": ["ممنون"],

        "lotfan": ["لطفاً"],
        "lotfan": ["لطفاً"],

        "eshgh": ["عشق"],
        "eshk": ["عشق"],

        "doost": ["دوست"],
        "dust": ["دوست"],

        "zendegi": ["زندگی"],
        "zendegy": ["زندگی"],

        "khane": ["خانه"],
        "khoone": ["خونه"],
        "khune": ["خونه"],

        "bache": ["بچه"],
        "bachche": ["بچه"],

        "dokhtar": ["دختر"],
        "dokhtar": ["دختر"],

        "pesar": ["پسر"],

        "emrooz": ["امروز"],
        "emruz": ["امروز"],

        "farda": ["فردا"],

        "alan": ["الان"],
        "al'an": ["الان"],

        "che": ["چه"],
        "chi": ["چی"],

        "koja": ["کجا"],
        "kojayi": ["کجایی"],

        "chera": ["چرا"],

        "are": ["آره"],
        "areh": ["آره"],

        "na": ["نه"],

        "bale": ["بله"],

        "khodafez": ["خداحافظ"],
        "khodahafez": ["خداحافظ"],

        "sobh": ["صبح"],
        "shab": ["شب"],

        "rooz": ["روز"],
        "ruz": ["روز"],

        "shoma": ["شما"],
        "man": ["من"],
        "to": ["تو"],
        "ma": ["ما"],
        "anha": ["آنها"],
        "oonha": ["اونا"],

        "mikham": ["می‌خوام", "می‌خواهم"],
        "mikhaam": ["می‌خوام", "می‌خواهم"],
        "mikhaham": ["می‌خواهم"],
        "mikhaam": ["می‌خوام", "می‌خواهم"],

        "nemikham": ["نمی‌خوام", "نمی‌خواهم"],
        "nemikhaam": ["نمی‌خوام", "نمی‌خواهم"],
        "nemikhaham": ["نمی‌خواهم"],

        "mishe": ["می‌شه", "می‌شود"],
        "misheh": ["می‌شه", "می‌شود"],
        "mishavad": ["می‌شود"],

        "mishe": ["می‌شه", "می‌شود"],

        "mikonam": ["می‌کنم"],
        "mikoni": ["می‌کنی"],
        "mikone": ["می‌کنه", "می‌کند"],
        "mikard": ["می‌کرد"],

        "nemikonam": ["نمی‌کنم"],
        "nemikoni": ["نمی‌کنی"],
        "nemikone": ["نمی‌کنه", "نمی‌کند"],

        "mitoonam": ["می‌تونم", "می‌توانم"],
        "mitunam": ["می‌تونم", "می‌توانم"],
        "mitavanam": ["می‌توانم"],

        "nemitoonam": ["نمی‌تونم", "نمی‌توانم"],
        "nemitunam": ["نمی‌تونم", "نمی‌توانم"],

        "bayad": ["باید"],
        "bayeh": ["بایه"],

        "daram": ["دارم"],
        "dari": ["داری"],
        "dare": ["داره"],
        "darim": ["داریم"],

        "nadaram": ["ندارم"],
        "nadari": ["نداری"],
        "nadare": ["نداره"],

        "ghalb": ["قلب"],
        "qalb": ["قلب"],

        "ghaza": ["غذا"],
        "qaza": ["غذا"],

        "ghalam": ["قلم"],
        "qalam": ["قلم"],

        "ghanoon": ["قانون"],
        "qanun": ["قانون"],

        "khosh": ["خوش"],
        "khoshhal": ["خوشحال"],

        "doostet": ["دوستت"],
        "dooset": ["دوستت"],

        "ashegh": ["عاشق"],
        "asheghet": ["عاشقت"],

        "khobam": ["خوبم"],
        "khoobam": ["خوبم"],

        "khobesh": ["خوبش"],
        "khoobesh": ["خوبش"]
    ]

    let generated = self._transliterator.transliterate(normalized)

    // Put high-confidence dictionary/colloquial forms first.
    var candidates: [String] = []
    var seen = Set<String>()

    if let preferred = common[normalized] {
        for word in preferred {
            if !seen.contains(word) {
                candidates.append(word)
                seen.insert(word)
            }
        }
    }

    for word in generated {
        if !seen.contains(word) {
            candidates.append(word)
            seen.insert(word)
        }
    }

    return wordStore.reorder(
        candidates,
        usingTable: PersianGoftamTransliterator.transliteratorName
    )
}

    func wordSelected(word: String) {
        wordStore.incrementTimesSelected(word,
                                         usingTable: PersianGoftamTransliterator.transliteratorName)
    }

}
