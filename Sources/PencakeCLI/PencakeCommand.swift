//
//  PencakeCommand.swift
//  pencake_parser
//
//  Created by k.haruyama on 2021/12/22.
//  
//

import Foundation
import ArgumentParser

@main
struct PencakeCommand: AsyncParsableCommand {
    static let configuration: CommandConfiguration = .init(
        commandName: "pencake",
        abstract: "Pencake Utilities",
        version: "version 0.6.0",
        subcommands: [ArticleCommand.self, StoryCommand.self],
        defaultSubcommand: StoryCommand.self
    )
}
