//
//  JSConfiguration.swift
//  Industrial Builder
//
//  Created by Artem on 02.03.2026.
//

import Foundation
import RegexBuilder
import LanguageSupport


private let jsReservedIdentifiers =
["await", "break", "case", "catch", "class", "const", "continue", "debugger", "default",
 "delete", "do", "else", "enum", "export", "extends", "false", "finally", "for", "function",
 "if", "import", "in", "instanceof", "let", "new", "null", "return", "super", "switch",
 "this", "throw", "true", "try", "typeof", "var", "void", "while", "with", "yield",
 "implements", "interface", "package", "private", "protected", "public", "static"]
private let jsReservedOperators =
[".", ",", ":", ";", "=", "=>", "?", "!", "==", "===", "!=", "!==",
 "+", "-", "*", "/", "%", "++", "--", "&&", "||", "<", "<=", ">", ">=",
 "&", "|", "^", "~", "<<", ">>", ">>>"]


extension LanguageConfiguration {
    
    /// Language configuration for JavaScript
    ///
    public static func javascript(_ languageService: LanguageService? = nil) -> LanguageConfiguration {
        
        let numberRegex: Regex<Substring> = Regex {
            optNegation
            ChoiceOf {
                Regex { "0b"; OneOrMore { CharacterClass("0"..."1") } }
                Regex { "0o"; OneOrMore { CharacterClass("0"..."7") } }
                Regex { "0x"; OneOrMore { CharacterClass("0"..."9", "a"..."f", "A"..."F") } }
                Regex { decimalLit; "."; decimalLit; Optionally { exponentLit } }
                Regex { decimalLit; exponentLit }
                decimalLit
            }
        }
        
        let identifierRegex: Regex<Substring> = Regex {
            CharacterClass(
                "a"..."z",
                "A"..."Z",
                .anyOf("_$")
            )
            ZeroOrMore {
                CharacterClass(
                    "a"..."z",
                    "A"..."Z",
                    "0"..."9",
                    .anyOf("_$")
                )
            }
        }
        
        let operatorRegex: Regex<Substring> = Regex {
            ChoiceOf {
                operatorHeadCharacters
                "."
            }
            ZeroOrMore {
                operatorCharacters
            }
        }
        
        return LanguageConfiguration(name: "JavaScript",
                                     supportsSquareBrackets: true,
                                     supportsCurlyBrackets: true,
                                     stringRegex: /"(?:\\.|[^"])*"|'(?:\\.|[^'])*'/,
                                     characterRegex: nil,
                                     numberRegex: numberRegex,
                                     singleLineComment: "//",
                                     nestedComment: (open: "/*", close: "*/"),
                                     identifierRegex: identifierRegex,
                                     operatorRegex: operatorRegex,
                                     reservedIdentifiers: jsReservedIdentifiers,
                                     reservedOperators: jsReservedOperators,
                                     languageService: languageService)
    }
}
