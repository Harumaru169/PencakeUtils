//
//  Article+Story.swift
//  pencake-parser
//
//  Created by k.haruyama on 2021/12/19.
//  
//

import Foundation

public struct Article: Codable {
    public var title: String
    
    public var editDate: Date
    
    public var body: String
}

public struct Story: Codable {
    public var title: String
    
    public var subtitle: String
    
    public var createdDate: Date
    
    public var exportedDate: Date
    
    public var articles: [Article]
}
