//
//  PencakeCommand.swift
//  pencake_parser
//
//  Created by k.haruyama on 2021/12/22.
//  
//

import Foundation
import ArgumentParser

struct PencakeCommand: ParsableCommand {
    static let configuration: CommandConfiguration = .init(
        commandName: "pencakeparser",
        abstract: "Pencake Utilities",
        discussion: "",
        version: "version 0.5.0",
        shouldDisplay: true,
        subcommands: [ArticleCommand.self, StoryCommand.self],
        defaultSubcommand: StoryCommand.self,
        helpNames: nil
    )
}
