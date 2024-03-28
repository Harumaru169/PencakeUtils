//
//
// The MIT License (MIT)
//
// Copyright (c) 2024 Kosei Haruyama.
//

import Foundation
import ImageIO
import os
import PencakeCore
import RegexBuilder
import UniformTypeIdentifiers
import ZIPFoundation

public final class SyncSerializer {
    public enum SerializationLogger {
        public static let standard: os.Logger = .init()
    }
    public let options: SerializeOptions
    
    private let articleJapaneseDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy年M月d日(EEEEE) HH:mm"
        df.locale = .init(identifier: "ja_JP")
        return df
    }()
    
    private let storyInfoJapaneseDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy/M/d HH:mm:ss"
        df.locale = .init(identifier: "ja_JP")
        return df
    }()
    
    private let newlineRegex = Regex {
        Newline.anyOfPencakeSupportedNewline
    }
    
    
    public init(options: SerializeOptions) {
        self.options = options
    }
    
    public func stringifiedArticle(_ article: Article) -> String {
        let dateString = articleJapaneseDateFormatter.string(from: article.editDate)
        let doubleNewline = options.newline.rawString + options.newline.rawString
        let newlineUnifiedBodyText = article.body.replacing(newlineRegex, with: { _ in options.newline.rawString })
        return article.title + doubleNewline + dateString + doubleNewline + newlineUnifiedBodyText
    }
    
    public func stringifiedStoryInfo(_ story: Story) -> String {
        let createdDateText = storyInfoJapaneseDateFormatter.string(from: story.createdDate)
        let exportedDateText = storyInfoJapaneseDateFormatter.string(from: story.exportedDate)
        let articleCountText = String(story.articles.count)
        let newlineString = options.newline.rawString
        
        var textList: [String] = [
            "# Title",
            story.title,
            "",
            "# Subtitle",
            story.subtitle,
            "",
            "# Created at",
            createdDateText,
            "",
            "# Exported at",
            exportedDateText,
            "",
            "# Article count",
            articleCountText,
            "",
            "# Articles"
        ]
        
        let articleList: [String] = story.articles.enumerated()
            .map { (index, article) in
                let number = index + 1
                return String(format: "%03d", number) + " - " + article.title
            }
        
        textList = textList + articleList + [""]
        
        return textList.joined(separator: newlineString)
    }
    
    //zipURLのところにはファイルなどが存在していないという前提。まだ、画像は含めてない。
    public func writeStoryZip(story: Story, to zipURL: URL) throws {
        guard let archive = Archive(url: zipURL, accessMode: .create) else {
            throw SerializeError.fileAlreadyExists(zipURL)
        }
        
        let storyInfoData = self.stringifiedStoryInfo(story).data(using: .utf8)!
        try archive.addEntry(with: "Story.txt", type: .file, uncompressedSize: Int64(storyInfoData.count)) { position, size in
            storyInfoData
        }
        
        try archive.addEntry(with: "Text", type: .directory, uncompressedSize: Int64(0)) { position, size in
            return .init()
        }
        
        for (index, article) in story.articles.enumerated() {
            let number = index + 1
            let relativePath = String(format: "Text/Article_%03d.txt", number)
            let articleData = self.stringifiedArticle(article).data(using: .utf8)!
            try archive.addEntry(with: relativePath, type: .file, uncompressedSize: Int64(articleData.count)) { position, size in
                articleData
            }
        }
        
        return //TODO: - ENABLE PHOTO SERIALIZATION
        
//        guard story.articles.lazy.flatMap(\.photos).isEmpty == false else { return }
//        //写真が一枚もない時はPhotosディレクトリはない。
//        try archive.addEntry(with: "Photos", type: .directory, uncompressedSize: Int64(0)) { position, size in
//                .init()
//        }
//        
//        let logger = SerializationLogger.standard
//        
//        for (articleIndex, article) in story.articles.enumerated() {
//            for (photoIndex, photo) in article.photos.enumerated() {
//                let articleNumber = articleIndex + 1
//                let photoNumber = photoIndex + 1
//                #if DEBUG
//                logger.info("start serializing photo \(articleNumber) \(photoNumber)")
//                #endif
//                let fileExtension: String
//                if let source = CGImageSourceCreateWithData(photo.data as CFData, nil),
//                   let uttypeStringCF = CGImageSourceGetType(source),
//                   let uttype = UTType(uttypeStringCF as String),
//                   let preferredFileExtension = uttype.preferredFilenameExtension {
//                    fileExtension = preferredFileExtension
//                } else {
//                    fileExtension = ""
//                }
//                
//                let relativePath = if photo.isTrimmedCoverPhoto {
//                    String(
//                        format: "Photos/IMG_%03d_%03d.%@",
//                        articleNumber, 0, fileExtension
//                    )
//                } else {
//                    String(
//                        format: "Photos/IMG_%03d_%03d.%@",
//                        articleNumber, photoNumber, fileExtension
//                    )
//                }
//                
//                try archive.addEntry(with: relativePath, type: .file, uncompressedSize: Int64(photo.data.count)) { position, size in
//                    photo.data
//                }
//                logger.info("finished serializing photo \(articleNumber) \(photoNumber)")
//            }
//        }
    }
}
