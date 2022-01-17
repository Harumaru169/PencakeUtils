//
//  ArticleParser.swift
//  pencake-parser
//
//  Created by k.haruyama on 2021/12/19.
//  
//

import Foundation
import Regex

public class ArticleParser {
    private init() {}
    
    public static let shared: ArticleParser = .init()
    
    private static let regex: Regex = "(.*?)(\n{2}|(?:\r\n){2})(.*?)\\2([\\s\\S]*)".r!
    
    public func parse(from data: Data, language: Language = .english) async throws -> Article {
        guard let text = String(data: data, encoding: .utf8) else {
            throw ArticleParsingError.invalidTextCoding
        }
        
        guard let match = Self.regex.findFirst(in: text) else {
            throw ArticleParsingError.dataCorrupted
        }
        
        let editDateString = match.group(at: 3)!
        let dateFormatter = language.dateFormatterForArticle
        guard let editDate = dateFormatter.date(from: editDateString)
        else {
            throw ArticleParsingError.invalidDateFormat(dateString: editDateString)
        }
        
        return Article(
            title: match.group(at: 1)!,
            editDate: editDate,
            body: match.group(at: 4)!
        )
    }
}

enum ArticleParsingError: Error {
    case invalidTextCoding
    
    case dataCorrupted
    
    case invalidDateFormat(dateString: String)
}
