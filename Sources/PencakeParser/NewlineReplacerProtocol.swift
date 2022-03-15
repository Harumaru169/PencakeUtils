//
//  NewlineReplacerProtocol.swift
//  
//
//  Created by k.haruyama on 2022/01/26.
//  
//

import Foundation
import PencakeCore

public protocol NewlineReplacerProtocol: Decodable, Sendable {
    func replaceAll(in: inout String, with: Newline)
    
    func replacingAll(in: String, with: Newline) -> String
}
