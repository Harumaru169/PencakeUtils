//
//  StoryParserProtocol.swift
//  
//
//  Created by k.haruyama on 2022/01/18.
//  
//

import Foundation

public protocol StoryParserProtocol: Decodable, Sendable {
    func parse(directoryURL: URL, options: ParseOptions) async throws -> Story
    
    func parse(zipFileURL: URL, options: ParseOptions) async throws -> Story
}

extension StoryParserProtocol {
    @available(*, deprecated, message: "Use 'parse(directoryURL:options:)' instead.")
    public func parse(directoryURL: URL, language: Language) async throws -> Story {
        return try await parse(directoryURL: directoryURL, options: .init(language: language))
    }
}
