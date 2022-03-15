//
//  ParseCommandOptions.swift
//  
//
//  Created by k.haruyama on 2022/01/30.
//  
//

import Foundation
import PencakeParser
import ArgumentParser

struct ParseCommandOptions: ParsableArguments {
    @Option(
        name: [.short, .customLong("lang")],
        help: "Language of the article's format. This will decide how to parse date expression.",
        completion: .list(Language.allCases.map(\.rawValue)),
        transform: { string in
            guard let result = Language(rawValue: string) else {
                throw TransformationError.invalidLanguage
            }
            return result
        })
    var language: Language = .english
    
    @Option(
        name: [.short, .customLong("newline-code")],
        help: "Newline code of output. If not specified, the same newline code as in the original file will be output.",
        completion: .list(Newline.allCases.map(\.rawValue)),
        transform: { string in
            guard let result = Newline(rawValue: string) else {
                throw TransformationError.invalidNewlineCode
            }
            return result
        })
    var newline: Newline?
    
    @Flag(
        name: [.customLong("pretty-printed"), .customShort("p")],
        help: "Print the JSON contents in pretty printed style."
    )
    var isFormatPrettyPrinted = false
    
    var parseOptions: ParseOptions {
        .init(language: language, newline: newline)
    }
}

extension ParseCommandOptions {
    enum TransformationError: Error, CustomStringConvertible {
        case invalidLanguage
        case invalidNewlineCode
        
        var description: String {
            switch self {
                case .invalidLanguage:
                    let languageCodes = Language.allCases.map { "'\($0.rawValue)'" }
                    return "Use \(languageCodes.formatted(.list(type: .or).locale(.init(identifier: "en_US_POSIX"))))."
                case .invalidNewlineCode:
                    let newlineCodes = Newline.allCases.map { "'\($0.rawValue)'" }
                    return "Use \(newlineCodes.formatted(.list(type: .or).locale(.init(identifier: "en_US_POSIX"))))."
            }
        }
    }
}
