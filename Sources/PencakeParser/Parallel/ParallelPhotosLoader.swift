//
// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.
//

import Foundation
import PencakeCore
import RegexBuilder

public final class ParallelPhotosLoader: ParallelPhotosLoaderProtocol {
    
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
    
    public func loadAllPhotos(in directoryURL: URL) async throws -> [Photo] {
        try checkURLIndicatesDirectory(url: directoryURL)
        
        let photoURLs: [URL] = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        
        return try await withThrowingTaskGroup(of: Photo?.self, returning: [Photo].self) { group in
            for photoURL in photoURLs {
                _ = group.addTaskUnlessCancelled {
                    guard let photoInfo = self.extractPhotoInfo(from: photoURL) else { return nil }
                    return try self.makePhoto(from: photoInfo)
                }
            }
            
            return try await Array(group.compactMap { $0 })
        }
    }
    
    public func loadPhotos(ofArticleNumber specifiedArticleNumber: Int, in directoryURL: URL) async throws -> [Photo] {
        try checkURLIndicatesDirectory(url: directoryURL)
        
        let photoURLs = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        
        return try await withThrowingTaskGroup(of: Photo?.self, returning: [Photo].self) { group in
            for photoURL in photoURLs {
                _ = group.addTaskUnlessCancelled { [self] in
                    guard let photoInfo = extractPhotoInfo(from: photoURL) else { return nil }
                    guard photoInfo.articleNumber == specifiedArticleNumber else { return nil }
                    return try makePhoto(from: photoInfo)
                }
            }
            
            return try await Array(group.compactMap { $0 })
        }
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

//FIXME: PencakeCoreへ移動させる
extension Array {
    init<S>(_ asyncSequence: S) async rethrows where Element == S.Element, S : AsyncSequence {
        self = try await asyncSequence.reduce(into: [Element](), { partialResult, element in
            partialResult.append(element)
        })
    }
}
