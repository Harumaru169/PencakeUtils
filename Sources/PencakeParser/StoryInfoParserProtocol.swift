//
//  StoryInfoParserProtocol.swift
//  
//
//  Created by k.haruyama on 2022/01/18.
//  
//

import Foundation
import PencakeCore

public protocol StoryInfoParserProtocol: Decodable, Sendable {
    func parse(from: Data) async throws -> StoryInformation
    
    func parse(fileURL: URL) async throws -> StoryInformation
}
