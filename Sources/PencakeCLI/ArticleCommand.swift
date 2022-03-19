//
// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.
//

import Foundation
import PencakeParser
import ArgumentParser

struct ArticleCommand: AsyncParsableCommand {
    
    static let configuration: CommandConfiguration = .init(
        commandName: "article",
        abstract: "Parses Pencake article and prints in JSON format"
    )
    
    @Argument(
        help: "Path to the file to read",
        completion: .file(extensions: ["txt"]),
        transform: { string in
            guard FileManager.default.fileExists(atPath: string) else {
                throw ExecutionError.fileDoesNotExist(path: string)
            }
            return string
        })
    var path: String
    
    @OptionGroup var commandOptions: ParseCommandOptions
    
    func run() async throws {
        let options = commandOptions.parseOptions
        
        let article = try await ArticleParser().parse(fileURL: URL(fileURLWithPath: path), options: options)
        
        let jsonEncoder = JSONEncoder()
        if commandOptions.isFormatPrettyPrinted {
            jsonEncoder.outputFormatting = .prettyPrinted
        }
        jsonEncoder.dateEncodingStrategy = .iso8601
        let jsonData = try jsonEncoder.encode(article)
        
        print(String(data: jsonData, encoding: .utf8)!)
    }
}

extension ArticleCommand {
    enum ExecutionError: Error, CustomStringConvertible {
        case fileDoesNotExist(path: String)
        
        case failedToReadData
        
        var description: String {
            switch self {
                case .fileDoesNotExist(let path):
                    return "The file does not exist: \(path)"
                case .failedToReadData:
                    return "Failed to read the contents of the file"
            }
        }
    }
}
