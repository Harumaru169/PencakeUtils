//
//  ArticleParser.swift
//  pencake-parser
//
//  Created by k.haruyama on 2021/12/19.
//  
//

import Foundation
import PencakeCore
import Regex

public final class ArticleParser<NewlineReplacerType: NewlineReplacerProtocol>: ArticleParserProtocol {
    
    private let newlineReplacer: NewlineReplacerType
    
    init(newlineReplacer: NewlineReplacerType) {
        self.newlineReplacer = newlineReplacer
    }
    
    private static var regex: Regex {
        "(.*?)(\n{2}|(?:\r\n){2})(.*?)\\2([\\s\\S]*)".r!
    }
    
    public func parse(from data: Data, options: ParseOptions) async throws -> Article {
        guard let text = String(data: data, encoding: .utf8) else {
            throw ParseError.invalidTextEncoding
        }
        
        guard let match = Self.regex.findFirst(in: text) else {
            throw ParseError.dataCorrupted
        }
        
        let title = match.group(at: 1)!
        
        let body: String
        if let newline = options.newline {
            body = newlineReplacer.replacingAll(in: match.group(at: 4)!, with: newline)
        } else {
            body = match.group(at: 4)!
        }
        
        let editDateString = match.group(at: 3)!
        let dateFormatter = DateFormatConstants.formatterForArticle(in: options.language)
        guard let editDate = dateFormatter.date(from: editDateString)
        else {
            throw ParseError.invalidDateFormat(dateString: editDateString)
        }
        
        return Article(title: title, editDate: editDate, body: body)
    }
    
    public func parse(fileURL: URL, options: ParseOptions) async throws -> Article {
        guard let data = FileManager.default.contents(atPath: fileURL.path) else {
            throw ParseError.failedToReadFile(fileName: fileURL.lastPathComponent)
        }
        
        return try await parse(from: data, options: options)
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
                    return "Invalid text encoding"
                case .dataCorrupted:
                    return "The content does not follow the format"
                case .invalidDateFormat(let dateString):
                    return "Invalid date format: \(dateString)"
                case .failedToReadFile(let fileName):
                    return "Failed to read \(fileName) file"
            }
        }
    }
}

extension ArticleParser where NewlineReplacerType == NewlineReplacer {
    public convenience init() {
        self.init(newlineReplacer: .init())
    }
}
