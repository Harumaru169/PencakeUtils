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
