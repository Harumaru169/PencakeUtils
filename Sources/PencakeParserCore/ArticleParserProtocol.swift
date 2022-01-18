//
//  ArticleParserProtocol.swift
//  
//
//  Created by k.haruyama on 2022/01/17.
//  
//

import Foundation

public protocol ArticleParserProtocol: Decodable {
    func parse(from: Data, language: Language) async throws -> Article
    
    func parse(fileURL: URL, language: Language) async throws -> Article
}
