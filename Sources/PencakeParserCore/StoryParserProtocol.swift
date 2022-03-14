//
//  StoryParserProtocol.swift
//  
//
//  Created by k.haruyama on 2022/01/18.
//  
//

import Foundation

public protocol StoryParserProtocol: Decodable, Sendable {
    @available(*, deprecated, message: "Use 'parse(storyInfoData:articleDatas:options:)' instead.")
    func parse(storyInfoData: Data, articleDatas: [Data], language: Language) async throws -> Story
    
    @available(*, deprecated, message: "Use 'parse(directoryURL:options:)' instead.")
    func parse(directoryURL: URL, language: Language) async throws -> Story
    
    func parse(storyInfoData: Data, articleDatas: [Data], options: ParseOptions) async throws -> Story
    
    func parse(directoryURL: URL, options: ParseOptions) async throws -> Story
    
    func parse(zipFileURL: URL, options: ParseOptions) async throws -> Story
}

extension StoryParserProtocol {
    public func parse(storyInfoData: Data, articleDatas: [Data], language: Language) async throws -> Story {
        return try await parse(storyInfoData: storyInfoData, articleDatas: articleDatas, options: .init(language: language))
    }
    
    public func parse(directoryURL: URL, language: Language) async throws -> Story {
        return try await parse(directoryURL: directoryURL, options: .init(language: language))
    }
}
