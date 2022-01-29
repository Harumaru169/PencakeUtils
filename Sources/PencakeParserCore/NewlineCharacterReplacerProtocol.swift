//
//  NewlineCharacterReplacerProtocol.swift
//  
//
//  Created by k.haruyama on 2022/01/26.
//  
//

import Foundation

public protocol NewlineCharacterReplacerProtocol: Decodable {
    func replaceAll(in: inout String, with: NewlineCharacter)
    
    func replacingAll(in: String, with: NewlineCharacter) -> String
}
