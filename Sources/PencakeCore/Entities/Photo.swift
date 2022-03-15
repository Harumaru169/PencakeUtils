//
//  Photo.swift
//  
//
//  Created by k.haruyama on 2022/02/17.
//  
//

import Foundation

public struct Photo: Codable, Equatable, Sendable {
    public var data: Data
    
    public var fileExtension: String
    
    public var isTrimmedCoverPhoto: Bool
    
    public init(data: Data, fileExtension: String, isTrimmedCoverPhoto: Bool) {
        self.data = data
        self.fileExtension = fileExtension
        self.isTrimmedCoverPhoto = isTrimmedCoverPhoto
    }
}
