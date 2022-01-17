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
                    throw ArticleCommandError.fileNotExists
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
                    throw ArticleCommandError.invalidLanguage
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
                throw ArticleCommandError.readingDataFailed
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
    
    struct ArticleCommandError: Error, CustomStringConvertible{
        var description: String
        
        init(_ description: String) {
            self.description = description
        }
        
        static let fileNotExists = Self.init("そんなファイルないよ。")
        
        static let readingDataFailed = Self.init("そんなもん読めへんわ。")
        
        static let invalidLanguage = Self.init("Invalid language specification. Please use \"english\" or \"japanese\".")
    }

}

