//
// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.
//

import XCTest
@testable import PencakeParser

class PhotosLoaderTests: XCTestCase {
    var directoryURL: URL?
    let fileManager = FileManager.default
    
    override func setUp() async throws {
        directoryURL = fileManager.temporaryDirectory.appendingPathComponent("PencakeParser.PhotosLoaderTests", isDirectory: true)
        if fileManager.fileExists(atPath: directoryURL!.path) {
            try fileManager.removeItem(at: directoryURL!)
        }
        try fileManager.createDirectory(at: directoryURL!, withIntermediateDirectories: true)
    }
    
    override func tearDown() async throws {
        try fileManager.removeItem(at: directoryURL!)
    }
    
    func testLoadingWithoutSpecifiedArticleNumber() throws {
        let photosDirectoryURL = directoryURL!.appendingPathComponent("Photos", isDirectory: true)
        try Constants.photosDirectoryFileWrapper.write(to: photosDirectoryURL, originalContentsURL: nil)
        
        let photosLoader = PhotosLoader()
        let photos = try photosLoader.load(from: photosDirectoryURL, articleNumber: nil)
        
        XCTAssertEqual(
            photos.filter { $0.isTrimmedCoverPhoto },
            Array(repeating: Constants.trimmedCoverPhoto, count: 3)
        )
        XCTAssertEqual(
            photos.filter { !$0.isTrimmedCoverPhoto },
            Array(repeating: Constants.regularPhoto, count: 9)
        )
    }
    
    func testLoadingWithSpecifiedArticleNumber() throws {
        //TODO: - implement this test case
        let photosDirectoryURL = directoryURL!.appendingPathComponent("Photos", isDirectory: true)
        try Constants.photosDirectoryFileWrapper.write(to: photosDirectoryURL, originalContentsURL: nil)
        
        let photosLoader = PhotosLoader()
        let photos = try photosLoader.load(from: photosDirectoryURL, articleNumber: 2)
        
        let expectedPhotos = Array(repeating: Constants.regularPhoto, count: 3) + [Constants.trimmedCoverPhoto]
        
        XCTAssertEqual(
            photos.filter { $0.isTrimmedCoverPhoto },
            expectedPhotos.filter { $0.isTrimmedCoverPhoto }
        )
        XCTAssertEqual(
            photos.filter { !$0.isTrimmedCoverPhoto },
            expectedPhotos.filter { !$0.isTrimmedCoverPhoto }
        )
    }
}

extension PhotosLoaderTests {
    enum Constants {
        static let data = "photo data".data(using: .utf8)!
        
        static let regularPhoto = Photo(data: data, fileExtension: "jpg", isTrimmedCoverPhoto: false)
        
        static let trimmedCoverPhoto = Photo(data: data, fileExtension: "jpg", isTrimmedCoverPhoto: true)
        
        static let photos: [Photo] = {
            return Array(repeating: regularPhoto, count: 9) + Array(repeating: trimmedCoverPhoto, count: 3)
        }()
        
        static let photosDirectoryFileWrapper: FileWrapper = {
            let photosDirectoryFileWrapper = FileWrapper(directoryWithFileWrappers: [:])
            
            for articleNumber in 1...3 {
                for photoNumber in 0...3 {
                    photosDirectoryFileWrapper.addRegularFile(
                        withContents: data,
                        preferredFilename: "IMG_\(String(format: "%03d", articleNumber))_\(String(format: "%03d", photoNumber)).jpg"
                    )
                }
            }
            
            return photosDirectoryFileWrapper
        }()
    }
}
