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
    
    @OptionGroup var commandOptions: ParseCommandOptions
    
    func runAsync() async throws {
        let options = commandOptions.parseOptions
        
        let story = try await StoryParser().parse(directoryURL: directoryURL, options: options)
        
        let jsonEncoder = JSONEncoder()
        if commandOptions.isFormatPrettyPrinted {
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
        
        var description: String {
            switch self {
                case .directoryDoesNotExist(path: let path):
                    return "The directory does not exist: \(path)"
            }
        }
    }
}
