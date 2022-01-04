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
    
    struct ArticleCommand: ParsableCommand {
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
        
        @Flag(
            name: [.customLong("pretty-printed"), .customShort("p")],
            help: "Print the JSON contents in pretty printed style."
        )
        var isFormatPrettyPrinted = false
        
        func run() async throws {
            guard let data = FileManager.default.contents(atPath: path) else {
                throw ArticleCommandError.readingDataFailed
            }
            
            let article = try await ArticleParser.shared.parse(from: data)
            
            let jsonEncoder = JSONEncoder()
            if isFormatPrettyPrinted {
                jsonEncoder.outputFormatting = .prettyPrinted
            }
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
    }

}

