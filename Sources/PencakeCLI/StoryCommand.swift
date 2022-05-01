//
// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.
//

import Foundation
import PencakeParser
import ArgumentParser

struct StoryCommand: AsyncParsableCommand {
    
    static let configuration = CommandConfiguration(
        commandName: "story",
        abstract: "Parses Pencake story and prints in JSON format"
    )
    
    @Argument(
        help: "Path to the directory or ZIP file to read",
        transform: { string in
            guard FileManager.default.fileExists(atPath: string) else {
                throw ExecutionError.itemDoesNotExist(path: string)
            }
            return URL(fileURLWithPath: string)
        })
    var itemURL: URL
    
    @OptionGroup var commandOptions: ParseCommandOptions
    
    @Flag(
        name: .customLong("include-photo-data"),
        help: "Include photo data in the output"
    ) var includePhotoData = false
    
    var jsonEncoder: JSONEncoder {
        let jsonEncoder = JSONEncoder()
        
        if self.commandOptions.isFormatPrettyPrinted {
            jsonEncoder.outputFormatting = .prettyPrinted
        }
        
        jsonEncoder.dateEncodingStrategy = .iso8601
        
        if !self.includePhotoData {
            jsonEncoder.dataEncodingStrategy = .custom({ _, encoder in
                var container = encoder.singleValueContainer()
                try container.encodeNil()
            })
        }
        
        return jsonEncoder
    }
    
    func run() async throws {
        let fileManager = FileManager.default
        let options = commandOptions.parseOptions
        var story: Story
        let storyParser = ParallelStoryParser()
        let itemFileType = try fileManager.type(at: itemURL)
        
        if itemFileType == .typeDirectory {
            story = try await storyParser.parse(directoryURL: itemURL, options: options)
        } else if itemFileType == .typeRegular {
            story = try await storyParser.parse(zipFileURL: itemURL, options: options)
        } else {
            throw ExecutionError.invalidFileType(type: itemFileType)
        }
        
        let jsonData = try jsonEncoder.encode(story)
        
        print(String(data: jsonData, encoding: .utf8) ?? "nil")
    }
}

extension StoryCommand {
    enum ExecutionError: Error, CustomStringConvertible {
        case itemDoesNotExist(path: String)
        
        case invalidFileType(type: FileAttributeType)
        
        var description: String {
            switch self {
                case .itemDoesNotExist(path: let path):
                    return "The directory or ZIP file does not exist: \(path)"
                case .invalidFileType(let type):
                    return "The file is neither a directory nor a regular file. it has file type '\(type.rawValue)'."
            }
        }
    }
}
