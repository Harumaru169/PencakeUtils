// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.

import Foundation
import ArgumentParser

@main
struct PencakeCommand: AsyncParsableCommand {
    static let configuration: CommandConfiguration = .init(
        commandName: "pencake",
        abstract: "Pencake Utilities",
        version: "version 0.6.1",
        subcommands: [ArticleCommand.self, StoryCommand.self],
        defaultSubcommand: StoryCommand.self
    )
}
