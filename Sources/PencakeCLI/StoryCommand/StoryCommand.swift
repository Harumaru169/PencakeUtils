//
// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.
//

import Foundation
import PencakeParser
import ArgumentParser

struct StoryCommand: AsyncParsableCommand {
    static let configuration: CommandConfiguration = .init(
        commandName: "story",
        abstract: "Story Utilities",
        subcommands: [StoryParseCommand.self, StoryToEPUBCommand.self]
    )
    
    enum ExecutionError: Error, CustomStringConvertible {
        case itemDoesNotExist(path: String)
        case invalidFileType(type: FileAttributeType)
        case fileAlreadyExist(path: String)
        
        var description: String {
            switch self {
                case .itemDoesNotExist(path: let path):
                    return "The directory or ZIP file does not exist: \(path)"
                case .invalidFileType(let type):
                    return "The file is neither a directory nor a regular file. it has file type '\(type.rawValue)'."
                case .fileAlreadyExist(path: let path):
                    return "No file should exist in the following path: \(path)"
            }
        }
    }
}
