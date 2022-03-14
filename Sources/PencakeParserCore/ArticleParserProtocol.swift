//
//  ArticleParserProtocol.swift
//  
//
//  Created by k.haruyama on 2022/01/17.
//  
//

import Foundation

public protocol ArticleParserProtocol: Decodable, Sendable {
    func parse(from: Data, options: ParseOptions) async throws -> Article
    
    func parse(fileURL: URL, options: ParseOptions) async throws -> Article
}
