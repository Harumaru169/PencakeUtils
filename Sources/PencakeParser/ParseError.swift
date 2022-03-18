//
//  ParseError.swift
//  
//
//  Created by 春山 恒誠 on 2022/03/18.
//

import Foundation
import PencakeCore

public enum ParseError: Error, CustomStringConvertible {
    case invalidTextEncoding
    
    case invalidFormat
    
    case invalidDateFormat(dateString: String)
    
    case failedToReadFile(path: String)
    
    case fileDoesNotExist(path: String)
    
    case unexpectedFileType(path: String, expected: FileAttributeType, actual: FileAttributeType)
    
    case failedToExtractZipFile(error: Error)
    
    case failedToParseStoryInfo(error: Error)
    
    case failedToParseArticle(path: String, error: Error)
    
    public var description: String {
        switch self {
            case .invalidTextEncoding:
                return "Invalid text encoding"
            case .invalidFormat:
                return "The content does not follow the format"
            case .invalidDateFormat(let dateString):
                return "Invalid date format: \(dateString)"
            case .failedToReadFile(let path):
                return "Failed to read \(path)"
            case .fileDoesNotExist(let path):
                return "\(path) does not exist"
            case let .unexpectedFileType(path, expected, actual):
                return "Expected the file '\(path)' to have file type '\(expected.rawValue)', but actually it has file type '\(actual.rawValue)'"
            case .failedToExtractZipFile(let error):
                return "Failed to extract ZIP file: \(error)"
            case .failedToParseStoryInfo(let error):
                return "Failed to parse story info: \(error)"
            case let .failedToParseArticle(path, error):
                return "Failed to parse \(path): \(error)"
        }
    }
}
