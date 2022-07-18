//
// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.
//

import Foundation
import PencakeCore
import RegexBuilder

public final class PhotosLoader: PhotosLoaderProtocol {
    
    public init() {}
    
    private let fileManager = FileManager.default
    
    private let fileNameRegex = Regex {
        "IMG_"
        TryCapture(OneOrMore(.digit)) { substring in
            Int(substring)
        }
        "_"
        TryCapture(OneOrMore(.digit)) { substring in
            Int(substring)
        }
        "."
        Capture {
            OneOrMore {
                CharacterClass.anyOf(".").inverted
            }
        }
    }
    
    @available(*, deprecated, message: "Use loadAllPhotos(in:) or loadPhotos(ofArticleNumber:in:) instead.")
    public func load(from directoryURL: URL, articleNumber specifiedArticleNumber: Int?) throws -> [Photo] {
        
        let fileType = try fileManager.type(at: directoryURL)
        guard fileType == .typeDirectory else {
            throw ParseError.unexpectedFileType(path: directoryURL.path, expected: .typeDirectory, actual: fileType)
        }
        
        if let specifiedArticleNumber {
            return try loadPhotos(ofArticleNumber: specifiedArticleNumber, in: directoryURL)
        } else {
            return try loadAllPhotos(in: directoryURL)
        }
    }
    
    public func loadAllPhotos(in directoryURL: URL) throws -> [Photo] {
        try checkURLIndicatesDirectory(url: directoryURL)
        
        let photoURLs: [URL] = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        
        return try photoURLs
            .compactMap { extractPhotoInfo(from: $0) }
            .map { try makePhoto(from: $0) }
    }
    
    public func loadPhotos(ofArticleNumber specifiedArticleNumber: Int, in directoryURL: URL) throws -> [Photo] {
        try checkURLIndicatesDirectory(url: directoryURL)
        
        let photoURLs: [URL] = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        
        let lazyPhotos = try photoURLs
            .lazy
            .compactMap { (photoURL: URL) -> PhotoInfo? in
                self.extractPhotoInfo(from: photoURL)
            }
            .filter { (photoInfo: PhotoInfo) -> Bool in
                photoInfo.articleNumber == specifiedArticleNumber
            }
            .map { (photoInfo: PhotoInfo) -> Photo in
                try makePhoto(from: photoInfo)
            }
        
        return Array(lazyPhotos)
    }
    
    private func checkURLIndicatesDirectory(url: URL) throws {
        let fileType = try fileManager.type(at: url)
        guard fileType == .typeDirectory else {
            throw ParseError.unexpectedFileType(path: url.path, expected: .typeDirectory, actual: fileType)
        }
    }
    
    private func extractPhotoInfo(from url: URL) -> PhotoInfo? {
        let fileName = url.lastPathComponent
        guard let output = fileName.wholeMatch(of: fileNameRegex)?.output else { return nil }
        return PhotoInfo(url: url, articleNumber: output.1, photoNumber: output.2, fileExtension: String(output.3))
    }
    
    private func makePhoto(from photoInfo: PhotoInfo) throws -> Photo {
        assert(photoInfo.url.pathExtension == photoInfo.fileExtension)
        
        guard let photoData = fileManager.contents(atPath: photoInfo.url.path) else {
            throw ParseError.failedToReadFile(path: photoInfo.url.path)
        }
        
        return Photo(data: photoData, fileExtension: photoInfo.fileExtension, isTrimmedCoverPhoto: photoInfo.photoNumber == 0)
    }
}
