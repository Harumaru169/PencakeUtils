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
    
    private static let jaDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ja_JP")
        df.dateFormat = "yyyy年MM月dd日(E) HH:mm"
        return df
    }()
    
    private static let enDateFormatter: DateFormatter = {
       let df = DateFormatter()
        df.locale = .init(identifier: "en_US")
        df.dateFormat = "EEE, MMM dd, yyyy hh:mm a"
        return df
    }()
    
    private static let regex: Regex = "(.*?)(\n{2}|(?:\r\n){2})(.*?)\\2([\\s\\S]*)".r!
    
    public func parse(from data: Data) async throws -> Article {
        guard let text = String(data: data, encoding: .utf8) else {
            throw ArticleParsingError.invalidTextCoding
        }
        
        guard let match = Self.regex.findFirst(in: text) else {
            throw ArticleParsingError.dataCorrupted
        }
        
        let editDateString = match.group(at: 3)!
        guard let editDate =
                Self.jaDateFormatter.date(from: editDateString) ??
                Self.enDateFormatter.date(from: editDateString)
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
