//
//  PhotosLoader.swift
//  
//
//  Created by k.haruyama on 2022/02/19.
//  
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
    
    public func load(from directoryURL: URL, articleNumber specifiedArticleNumber: Int?) async throws -> [Photo] {
        let fileManager = FileManager.default
        let photoURLs: [URL] = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        
        return try await withThrowingTaskGroup(of: Photo?.self, returning: [Photo].self) { group in
            for photoURL in photoURLs {
                _ = group.addTaskUnlessCancelled {
                    let fileName = photoURL.lastPathComponent
                    
                    guard let match = Self.fileNameRegex.findFirst(in: fileName) else {
                        return nil
                    }
                    
                    let articleNumberString = match.group(named: "articleNumber")!
                    guard let articleNumber = Int(articleNumberString) else {
                        throw LoadError.invalidNumberFormat(numberString: articleNumberString)
                    }
                    
                    if let specifiedArticleNumber = specifiedArticleNumber, articleNumber != specifiedArticleNumber {
                        return nil
                    }
                            
                    let photoNumberString = match.group(named: "photoNumber")!
                    guard let photoNumber = Int(photoNumberString) else {
                        throw LoadError.invalidNumberFormat(numberString: photoNumberString)
                    }
                    
                    guard let photoData = fileManager.contents(atPath: photoURL.path) else {
                        throw LoadError.failedToReadFile(fileName: fileName)
                    }
                    
                    return Photo(
                        data: photoData,
                        fileExtension: photoURL.pathExtension,
                        isTrimmedCoverPhoto: photoNumber == 0
                    )
                }
            }
            
            var results: [Photo] = []
            
            for try await photo in group {
                if let photo = photo {
                    results.append(photo)
                }
            }
            
            return results
        }
    }
}

extension PhotosLoader {
    public enum LoadError: Error, CustomStringConvertible {
        //TODO: unnecessary
        case fileNameCorrupted(fileName: String)
        
        case invalidNumberFormat(numberString: String)
        
        case failedToReadFile(fileName: String)
        
        public var description: String {
            switch self {
                case .fileNameCorrupted(let fileName):
                    return "Corrupted file name: \(fileName)"
                case .invalidNumberFormat(let numberString):
                    return "Invalid number format: \(numberString)"
                case .failedToReadFile(let fileName):
                    return "Failed to read \(fileName)"
            }
        }
    }
}
