//
// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.
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
        "(.*?)(\(Newline.regexMatchingAnyNewline)){2}(.*?)\\2{2}([\\s\\S]*)".r!
    }
    
    public func parse(from data: Data, options: ParseOptions) async throws -> Article {
        guard let text = String(data: data, encoding: .utf8) else {
            throw ParseError.invalidTextEncoding
        }
        
        guard let match = Self.regex.findFirst(in: text) else {
            throw ParseError.invalidFormat
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
            throw ParseError.failedToReadFile(path: fileURL.path)
        }
        
        return try await parse(from: data, options: options)
    }
}

extension ArticleParser where NewlineReplacerType == NewlineReplacer {
    public convenience init() {
        self.init(newlineReplacer: .init())
    }
}
