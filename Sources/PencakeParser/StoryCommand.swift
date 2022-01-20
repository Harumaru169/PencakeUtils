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
        abstract: "Parses a Pencake article and prints in JSON format."
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
    
    @Flag(
        name: [.customLong("pretty-printed"), .customShort("p")],
        help: "Print the JSON contents in pretty printed style."
    )
    var isFormatPrettyPrinted = false
    
    
    
    func runAsync() async throws {
        let story = try await StoryParser(articleParser: ArticleParser(), storyInfoParser: StoryInfoParser()).parse(directoryURL: directoryURL, language: language)
        
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
        
        var description: String {
            switch self {
                case .directoryDoesNotExist(path: let path):
                    return "The file does not exist: \(path)"
                case .invalidLanguage:
                    return "Invalid language specification. Please use \(Language.allCases.map(\.rawValue).formatted(.list(type: .or).locale(.init(identifier: "en_US_POSIX"))))."
            }
        }
    }
}
