//
//  StoryCommand.swift
//  pencake_parser
//
//  Created by k.haruyama on 2021/12/22.
//  
//

import Foundation
import PencakeParserCore
import ArgumentParser

struct StoryCommand: AsyncParsableCommand {
    
    static let configuration = CommandConfiguration(
        commandName: "story",
        abstract: "Parses a Pencake story and prints in JSON format."
    )
    
    @Argument(
        help: "Path to the directory to read.",
        completion: .directory,
        transform: { string in
            guard FileManager.default.fileExists(atPath: string) else {
                throw ExecutionError.directoryDoesNotExist(path: string)
            }
            return URL(fileURLWithPath: string)
        })
    var directoryURL: URL
    
    @Option(
        name: [.customLong("language"), .customShort("l")],
        help: "Language of the story. This will be used to parse dates.",
        completion: .list(Language.allCases.map(\.rawValue)),
        transform: { string in
            guard let result = Language(rawValue: string) else {
                throw ExecutionError.invalidLanguage
            }
            return result
        })
    var language: Language = .english
    
    @Option(
        name: [.short, .customLong("newline-code")],
        help: "Newline code for text. If not specified, the same newline code as in the original file will be used.",
        completion: .list(NewlineCharacter.allCases.map(\.rawValue)),
        transform: { string in
            guard let result = NewlineCharacter(rawValue: string) else {
                throw ExecutionError.invalidNewlineCode
            }
            return result
        })
    var newlineCharacter: NewlineCharacter? = nil
    
    @Flag(
        name: [.customLong("pretty-printed"), .customShort("p")],
        help: "Print the JSON contents in pretty printed style."
    )
    var isFormatPrettyPrinted = false
    
    
    
    func runAsync() async throws {
        let options = ParseOptions(language: language, replaceNewlineCharWith: newlineCharacter)
        
        let story = try await StoryParser().parse(directoryURL: directoryURL, options: options)
        
        let jsonEncoder = JSONEncoder()
        if isFormatPrettyPrinted {
            jsonEncoder.outputFormatting = .prettyPrinted
        }
        jsonEncoder.dateEncodingStrategy = .iso8601
        let jsonData = try jsonEncoder.encode(story)
        
        print(String(data: jsonData, encoding: .utf8) ?? "nil")
    }
}

extension StoryCommand {
    enum ExecutionError: Error, CustomStringConvertible {
        case directoryDoesNotExist(path: String)
        
        case invalidLanguage
        
        case invalidNewlineCode
        
        var description: String {
            switch self {
                case .directoryDoesNotExist(path: let path):
                    return "The directory does not exist: \(path)"
                case .invalidLanguage:
                    return "Use \(Language.allCases.map(\.rawValue).formatted(.list(type: .or).locale(.init(identifier: "en_US_POSIX"))))."
                case .invalidNewlineCode:
                    return "Use \(NewlineCharacter.allCases.map(\.rawValue).formatted(.list(type: .or).locale(.init(identifier: "en_US_POSIX"))))."
            }
        }
    }
}
