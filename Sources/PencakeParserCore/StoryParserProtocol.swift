//
//  StoryParserProtocol.swift
//  
//
//  Created by k.haruyama on 2022/01/18.
//  
//

import Foundation

public protocol StoryParserProtocol: Decodable {
    func parse(storyInfoData: Data, articleDatas: [Data], language: Language) async throws -> Story
    
    func parse(directoryURL: URL, language: Language) async throws -> Story
}
