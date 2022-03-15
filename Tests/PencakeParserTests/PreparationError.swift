//
//  File.swift
//  
//
//  Created by k.haruyama on 2022/01/19.
//  
//

struct PreparationError: Error, CustomStringConvertible {
    var description: String
    
    init(_ description: String) {
        self.description = description
    }
}
