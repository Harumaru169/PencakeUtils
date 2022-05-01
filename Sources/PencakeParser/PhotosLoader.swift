//
// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.
//

import Foundation
import PencakeCore
import Regex

public final class PhotosLoader: PhotosLoaderProtocol {
    
    public init() {}
    
    private static let fileNameRegex = try! Regex(
        pattern: #"^IMG_([0-9]+)_([0-9]+)\.([^\.]+)$"#,
        groupNames: "articleNumber", "photoNumber", "fileExtension"
    )
    
    public func load(from directoryURL: URL, articleNumber specifiedArticleNumber: Int?) throws -> [Photo] {
        let fileManager = FileManager.default
        
        let fileType = try fileManager.type(at: directoryURL)
        guard fileType == .typeDirectory else {
            throw ParseError.unexpectedFileType(path: directoryURL.path, expected: .typeDirectory, actual: fileType)
        }
        
        let photoURLs: [URL] = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        
        return try photoURLs.compactMap { photoURL throws -> Photo? in
            let fileName = photoURL.lastPathComponent
            
            guard let match = Self.fileNameRegex.findFirst(in: fileName) else {
                return nil
            }
            
            let articleNumberString = match.group(named: "articleNumber")!
            let articleNumber = Int(articleNumberString)!
            
            if let specifiedArticleNumber = specifiedArticleNumber, articleNumber != specifiedArticleNumber {
                return nil
            }
            
            let photoNumberString = match.group(named: "photoNumber")!
            let photoNumber = Int(photoNumberString)!
            
            guard let photoData = fileManager.contents(atPath: photoURL.path) else {
                throw ParseError.failedToReadFile(path: photoURL.path)
            }
            
            return Photo(
                data: photoData,
                fileExtension: photoURL.pathExtension,
                isTrimmedCoverPhoto: photoNumber == 0
            )
        }
    }
}
