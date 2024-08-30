//
//
// The MIT License (MIT)
//
// Copyright (c) 2024 Kosei Haruyama.
//

import ArgumentParser
import Foundation
import PencakeEPUBConverter

extension StoryCommand {
    struct StoryToEPUBCommand: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "toepub",
            abstract: "Converts a PenCake story to EPUB format"
        )
        
        @Argument(
            transform: { string in
                guard FileManager.default.fileExists(atPath: string) else {
                    throw ExecutionError.itemDoesNotExist(path: string)
                }
                return URL(fileURLWithPath: string)
            })
        var inputURL: URL
        
        @Argument(
            transform: URL.init(fileURLWithPath:)
        )
        var outputURL: URL
        
        @Argument var authorName: String
        
        @Flag(
            name: .shortAndLong,
            help: "don't overwrite existing files"
        )
        var noClobber: Bool = false
        
        @OptionGroup var commandOptions: ParseCommandOptions
        
        func run() async throws {
            let fileManager = FileManager.default
            
            guard  (noClobber && fileManager.fileExists(atPath: outputURL.path())) == false else {
                throw ExecutionError.fileAlreadyExist(path: outputURL.path())
            }
            if FileManager.default.fileExists(atPath: outputURL.path()) {
                try FileManager.default.removeItem(at: outputURL)
            }
            
            let parseOptions = commandOptions.parseOptions
            var story: Story
            let storyParser = ParallelStoryParser()
            let itemFileType = try fileManager.type(at: inputURL)
            
            if itemFileType == .typeDirectory {
                story = try await storyParser.parse(directoryURL: inputURL, options: parseOptions)
            } else if itemFileType == .typeRegular {
                story = try await storyParser.parse(zipFileURL: inputURL, options: parseOptions)
            } else {
                throw ExecutionError.invalidFileType(type: itemFileType)
            }
            
            let converter = EPUBConverter()
            let convertOptions = EPUBConverter.Options(authorName: authorName, isWrittenVertically: false)
            try converter.write(story: story, to: outputURL, options: convertOptions)
        }
    }
}
