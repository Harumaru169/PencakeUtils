//
//  StoryInfoParserProtocol.swift
//  
//
//  Created by k.haruyama on 2022/01/18.
//  
//

import Foundation

public protocol StoryInfoParserProtocol: Decodable, Sendable {
    func parse(from: Data) async throws -> (Story, articleCount: Int)
    
    func parse(fileURL: URL) async throws -> (Story, articleCount: Int)
}
