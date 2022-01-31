//
//  ArticleParserProtocol.swift
//  
//
//  Created by k.haruyama on 2022/01/17.
//  
//

import Foundation

public protocol ArticleParserProtocol: Decodable, Sendable {
    @available(*, deprecated, message: "Use 'parse(from:options:)' instead.")
    func parse(from: Data, language: Language) async throws -> Article
    
    @available(*, deprecated, message: "Use 'parse(fileURL:options:)' instead.")
    func parse(fileURL: URL, language: Language) async throws -> Article
    
    func parse(from: Data, options: ParseOptions) async throws -> Article
    
    func parse(fileURL: URL, options: ParseOptions) async throws -> Article
}

extension ArticleParserProtocol {
    public func parse(from data: Data, language: Language) async throws -> Article {
        try await self.parse(from: data, options: .init(language: language))
    }
    
    public func parse(fileURL: URL, language: Language) async throws -> Article {
        try await self.parse(fileURL: fileURL, options: .init(language: language))
    }
}
