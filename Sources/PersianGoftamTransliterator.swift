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
    let normalized = normalizePinglish(input)

    // High-confidence Persian transliterations.
    // These are intentionally limited to common forms;
    // the normal Goftam engine handles everything else.
    let shortcuts: [String: [String]] = [
        "salam": ["سلام"],
        "salaam": ["سلام"],

        "chetori": ["چطوری"],
        "chetoori": ["چطوری"],

        "khobi": ["خوبی"],
        "khoobi": ["خوبی"],
        "khob": ["خوب"],
        "khoob": ["خوب"],

        "doost": ["دوست"],
        "dust": ["دوست"],

        "eshgh": ["عشق"],
        "eshq": ["عشق"],

        "ghalb": ["قلب"],
        "qalb": ["قلب"],

        "ghaza": ["غذا"],
        "qaza": ["غذا"],

        "khane": ["خانه"],
        "khune": ["خونه"],
        "khoone": ["خونه"],

        "merci": ["مرسی"],
        "mersi": ["مرسی"],

        "mamnoon": ["ممنون"],
        "mamnon": ["ممنون"],

        "lotfan": ["لطفاً"],

        "emrooz": ["امروز"],
        "emruz": ["امروز"],

        "farda": ["فردا"],
        "alan": ["الان"],

        "are": ["آره"],
        "areh": ["آره"],

        "bale": ["بله"],

        "khodafez": ["خداحافظ"],
        "khodahafez": ["خداحافظ"],

        "mikham": ["می‌خوام", "می‌خواهم"],
        "mikhaam": ["می‌خوام", "می‌خواهم"],
        "mikhaham": ["می‌خواهم"],

        "nemikham": ["نمی‌خوام", "نمی‌خواهم"],
        "nemikhaam": ["نمی‌خوام", "نمی‌خواهم"],
        "nemikhaham": ["نمی‌خواهم"],

        "mishe": ["می‌شه", "می‌شود"],
        "misheh": ["می‌شه", "می‌شود"],

        "mikonam": ["می‌کنم"],
        "mikoni": ["می‌کنی"],
        "mikone": ["می‌کنه", "می‌کند"],

        "nemikonam": ["نمی‌کنم"],
        "nemikoni": ["نمی‌کنی"],
        "nemikone": ["نمی‌کنه", "نمی‌کند"],

        "mitoonam": ["می‌تونم", "می‌توانم"],
        "mitunam": ["می‌تونم", "می‌توانم"],
        "mitavanam": ["می‌توانم"],

        "nemitoonam": ["نمی‌تونم", "نمی‌توانم"],
        "nemitunam": ["نمی‌تونم", "نمی‌توانم"],

        "bayad": ["باید"],

        "daram": ["دارم"],
        "dari": ["داری"],
        "dare": ["داره"],
        "darim": ["داریم"],

        "nadaram": ["ندارم"],
        "nadari": ["نداری"],
        "nadare": ["نداره"]
    ]

    var generated: [String] = []

    for variant in phoneticVariants(normalized) {
        generated.append(
            contentsOf: _transliterator.transliterate(variant)
    )
    }

    var candidates: [String] = []
    var seen = Set<String>()

    // Put high-confidence forms first.
    if let preferred = shortcuts[normalized] {
        for word in preferred where !seen.contains(word) {
            candidates.append(word)
            seen.insert(word)
        }
    }

    // Then add normal Goftam candidates.
    for word in generated where !seen.contains(word) {
        candidates.append(word)
        seen.insert(word)
    }

    // Finally apply Goftam's existing user-learning/dictionary ranking.
    let reordered = wordStore.reorder(
        candidates,
        usingTable: PersianGoftamTransliterator.transliteratorName
    )
    
    return rankPersianCandidates(
        reordered,
        input: normalized
    )
}

private func normalizePinglish(_ input: String) -> String {
    var value = input.lowercased()

    // Normalize common Persian/Pinglish spelling variations.
    value = value.replacingOccurrences(of: "ā", with: "aa")
    value = value.replacingOccurrences(of: "á", with: "a")
    value = value.replacingOccurrences(of: "í", with: "i")
    value = value.replacingOccurrences(of: "ī", with: "i")
    value = value.replacingOccurrences(of: "ó", with: "o")
    value = value.replacingOccurrences(of: "ú", with: "u")
    value = value.replacingOccurrences(of: "ū", with: "u")

    // x is already supported by Goftam as خ.
    // q and gh both remain available for ق/غ.
    // Normalize alternate doubled-vowel spellings.
    value = value.replacingOccurrences(of: "aaaa", with: "aa")
    value = value.replacingOccurrences(of: "ooo", with: "oo")
    value = value.replacingOccurrences(of: "uuu", with: "uu")

    return value
}

private func phoneticVariants(_ input: String) -> [String] {
    var variants = [input]

    let replacements: [(String, [String])] = [
        ("aa", ["a", "aa"]),
        ("ee", ["i", "e"]),
        ("ii", ["i"]),
        ("oo", ["u", "o"]),
        ("uu", ["u"]),
        ("ou", ["u", "o"]),
        ("ow", ["u", "o"]),

        ("kh", ["kh", "x"]),
        ("gh", ["gh", "q"]),

        ("sh", ["sh"]),
        ("ch", ["ch"]),
        ("zh", ["zh"])
    ]

    for (pattern, alternatives) in replacements {
        var next: [String] = []

        for variant in variants {
            if variant.contains(pattern) {
                for replacement in alternatives {
                    next.append(
                        variant.replacingOccurrences(
                            of: pattern,
                            with: replacement
                        )
                    )
                }
            }
        }

        variants.append(contentsOf: next)
    }

    var result: [String] = []
    var seen = Set<String>()

    for variant in variants {
        if !seen.contains(variant) {
            result.append(variant)
            seen.insert(variant)
        }
    }

    return result
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

private func rankPersianCandidates(
    _ candidates: [String],
    input: String
) -> [String] {

    let preferred: Set<String> = [
        "سلام", "خوب", "خوبی", "خانه", "خونه",
        "دوست", "عشق", "قلب", "غذا", "زندگی",
        "امروز", "فردا", "الان", "چطوری",
        "ممنون", "مرسی", "لطفاً",
        "باید", "من", "تو", "ما", "شما",
        "آره", "نه", "بله",
        "می‌خواهم", "می‌خوام",
        "نمی‌خواهم", "نمی‌خوام",
        "می‌شود", "می‌شه",
        "می‌کنم", "می‌کنی", "می‌کنه",
        "می‌توانم", "می‌تونم"
    ]

    var scored: [(word: String, score: Int, index: Int)] = []

    for (index, word) in candidates.enumerated() {
        var score = 0

        // Strong preference for known common Persian words.
        if preferred.contains(word) {
            score += 100
        }

        // Avoid extremely unlikely candidates.
        if word.contains("ع") {
            score -= 2
        }

        // Prefer normal Persian orthography.
        if word.contains("هٔ") {
            score -= 1
        }

        // Prefer shorter candidates when otherwise equivalent.
        score -= max(0, word.count - input.count)

        scored.append(
            (
                word: word,
                score: score,
                index: index
            )
        )
    }

    scored.sort {
        if $0.score != $1.score {
            return $0.score > $1.score
        }

        return $0.index < $1.index
    }

    return scored.map { $0.word }
}

    func wordSelected(word: String) {
        wordStore.incrementTimesSelected(word,
                                         usingTable: PersianGoftamTransliterator.transliteratorName)
    }

}
