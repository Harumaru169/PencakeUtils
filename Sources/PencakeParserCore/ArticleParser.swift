//
//  ArticleParser.swift
//  pencake-parser
//
//  Created by k.haruyama on 2021/12/19.
//  
//

import Foundation
import Regex

public class ArticleParser: ArticleParserProtocol {
    public init() {}
    
    private static let regex: Regex = "(.*?)(\n{2}|(?:\r\n){2})(.*?)\\2([\\s\\S]*)".r!
    
    public func parse(from data: Data, options: ParseOptions) async throws -> Article {
        guard let text = String(data: data, encoding: .utf8) else {
            throw ParseError.invalidTextEncoding
        }
        
        guard let match = Self.regex.findFirst(in: text) else {
            throw ParseError.dataCorrupted
        }
        
        let editDateString = match.group(at: 3)!
        let dateFormatter = options.language.dateFormatterForArticle
        guard let editDate = dateFormatter.date(from: editDateString)
        else {
            throw ParseError.invalidDateFormat(dateString: editDateString)
        }
        
        return Article(
            title: match.group(at: 1)!,
            editDate: editDate,
            body: match.group(at: 4)!
        )
    }
    
    public func parse(fileURL: URL, options: ParseOptions) async throws -> Article {
        guard let data = FileManager.default.contents(atPath: fileURL.path) else {
            throw ParseError.failedToReadFile(fileName: fileURL.lastPathComponent)
        }
        
        return try await parse(from: data, language: options.language)
    }
}

extension ArticleParser {
    public enum ParseError: Error, CustomStringConvertible {
        case invalidTextEncoding
        
        case dataCorrupted
        
        case invalidDateFormat(dateString: String)
        
        case failedToReadFile(fileName: String)
        
        public var description: String {
            switch self {
                case .invalidTextEncoding:
                    return "Invalid text encoding."
                case .dataCorrupted:
                    return "The content does not follow the format."
                case .invalidDateFormat(let dateString):
                    return "Invalid date format: \(dateString)"
                case .failedToReadFile(let fileName):
                    return "Failed to read \(fileName) file."
            }
        }
    }
}
