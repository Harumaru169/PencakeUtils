//
//  ArticleCommand.swift
//  pencake_parser
//
//  Created by k.haruyama on 2021/12/22.
//  
//

import Foundation
import PencakeParserCore
import ArgumentParser

extension PencakeCommand {
    
    struct ArticleCommand: AsyncParsableCommand {
        static let configuration: CommandConfiguration = .init(
            commandName: "article",
            abstract: "Parses a Pencake article and prints in JSON format."
        )
        
        @Argument(
            help: "Path to the file to read.",
            completion: .file(extensions: ["txt"]),
            transform: { string in
                guard FileManager.default.fileExists(atPath: string) else {
                    throw ExecutionError.fileDoesNotExist(path: string)
                }
                return string
            })
        var path: String
        
        @Option(
            name: [.short, .customLong("lang")],
            help: "Language of the article. This will be used to parse dates.",
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
            guard let data = FileManager.default.contents(atPath: path) else {
                throw ExecutionError.failedToReadData
            }
            
            let article = try await ArticleParser.shared.parse(from: data, language: language)
            
            let jsonEncoder = JSONEncoder()
            if isFormatPrettyPrinted {
                jsonEncoder.outputFormatting = .prettyPrinted
            }
            jsonEncoder.dateEncodingStrategy = .iso8601
            let jsonData = try jsonEncoder.encode(article)
            
            print(String(data: jsonData, encoding: .utf8)!)
        }
    }
}

extension PencakeCommand.ArticleCommand {
    enum ExecutionError: Error, CustomStringConvertible {
        case fileDoesNotExist(path: String)
        
        case failedToReadData
        
        case invalidLanguage
        
        var description: String {
            switch self {
                case .fileDoesNotExist(let path):
                    return "The file does not exist: \(path)"
                case .failedToReadData:
                    return "Failed to read the contents of the file."
                case .invalidLanguage:
                    return "Invalid language specification. Please use \(Language.allCases.map(\.rawValue).formatted(.list(type: .or).locale(.init(identifier: "en_US_POSIX"))))."
            }
        }
    }
}
