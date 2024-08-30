//
// The MIT License (MIT)
//
// Copyright (c) 2024 Kosei Haruyama.
//

import Foundation
@_exported import PencakeCore
@_exported import PencakeParser
import ZIPFoundation

public struct EPUBConverter {
    public struct Options {
        public var authorName: String
        public var isWrittenVertically: Bool
    }
    
    public enum ConvertError: Error {
        case failedToCreateFile(path: String)
    }
    
    public func write(story: Story, to destinationURL: URL, options: Options) throws {
        let mimetypeData = Templates.mimetype().data(using: .utf8)!
        
        let containerXMLData = Templates.containerXML().data(using: .utf8)!
        
        let iBooksDisplayOptionsData = Templates.iBooksDisplayOptions().data(using: .utf8)!
        
        let pageSectionInPackageFile: String = story.articles.enumerated().map { (index, article) -> String in
            let articleNumber = index + 1
            return """
        <item id="page\(articleNumber)" href="Texts/page\(articleNumber).xhtml" media-type="application/xhtml+xml"/>

"""
        }
        .joined()
        
        let imageSectionInPackageFile: String = story.articles.enumerated().flatMap { (articleIndex, article) -> [String] in
            article.photos.enumerated().map { (photoIndex, photo) -> String in
                let name = "image\(articleIndex+1)-\(photoIndex+1)"
                return """
        <item id="\(name)" href="Images/\(name).\(jpgTojpeg(photo.fileExtension))" media-type="image/\(jpgTojpeg(photo.fileExtension))"/>

"""
            }
        }
        .joined()
        
        let spineSectionInPackageFile: String = story.articles.enumerated().map { (index, article) -> String in
            let articleNumber = index + 1
            return """
        <itemref idref="page\(articleNumber)"/>

"""
        }.joined()
        
        let packageFileData = """
<?xml version="1.0" encoding="UTF-8"?>
<package xmlns="http://www.idpf.org/2007/opf" version="3.0" unique-identifier="BookId">
    <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
        <dc:title>\(modifyStringForXHTML(story.title))</dc:title>
        <dc:creator>\(modifyStringForXHTML(options.authorName))</dc:creator>
        <dc:identifier id="BookId">urn:uuid:1B9E19D2-FF3F-4019-B394-6F866F5C5E38</dc:identifier>
        <dc:language>ja</dc:language>
        <meta property="dcterms:modified">\(Date.now.formatted(.iso8601))</meta>
        \(options.isWrittenVertically ? """
<meta name="primary-writing-mode" content="vertical-rl" />
""" : "")
    </metadata>
    <manifest>
        <item id="nav" href="\(Templates.navFileName)" media-type="application/xhtml+xml" properties="nav"/>
        <item media-type="text/css" id="book-style" href="Styles/styles.css" />
\(pageSectionInPackageFile)
\(imageSectionInPackageFile)
    </manifest>
    \(options.isWrittenVertically ? """
    <spine page-progression-direction="rtl">
""" : "<spine>")
\(spineSectionInPackageFile)
    </spine>
</package>
""".data(using: .utf8)!
        
        let pageSectionInNavFile: String = story.articles.enumerated().map { (index, article) in
            let articleNumber = index + 1
            let escapedTitle = modifyStringForXHTML(article.title)
            return """
            <li><a href="./Texts/page\(articleNumber).xhtml">\(escapedTitle)</a></li>

"""
        }
        .joined()
        
        let navFileData = """
<?xml version="1.0" encoding="UTF-8"?>
<html xmlns="http://www.w3.org/1999/xhtml"
      xmlns:epub="http://www.idpf.org/2007/ops">
<head>
    <title>\(modifyStringForXHTML(story.title)) - 目次</title>
</head>
<body style="font-family:PrimaryFont">
    <nav epub:type="toc">
        <h1>目次</h1>
        <ol>
\(pageSectionInNavFile)
        </ol>
    </nav>
</body>
</html>
""".data(using: .utf8)!
        
        let pageXHTMLDataGenerator = { (articleNumber: Int, article: PencakeCore.Article) -> Data in
            let imageSection: String = article.photos.enumerated().map { (photoIndex, photo) -> String in
                return """
        <img id="img-in-page" src="../Images/image\(articleNumber)-\(photoIndex+1).\(jpgTojpeg(photo.fileExtension))" alt="画像\(articleNumber)-\(photoIndex+1)"/>

"""
            }
            .joined()
            
            let escapedArticleTitle = modifyStringForXHTML(article.title)
            
            return """
<?xml version="1.0" encoding="UTF-8"?>
<html xmlns="http://www.w3.org/1999/xhtml">
 <head>
    <title>\(modifyStringForXHTML(story.title)) - \(escapedArticleTitle)</title>
    <link rel="stylesheet" type="text/css" href="../Styles/styles.css" />
</head>
<body>
    <h1 id="header">\(escapedArticleTitle)</h1>
    <pre style="font-family:PrimaryFont" id="body">\(modifyStringForXHTML(article.body))</pre>
    <div id="img-grid">
\(imageSection)
    </div>
</body>
</html>
""".data(using: .utf8)!
        }
        
        let cssFileData = """
\(options.isWrittenVertically ? """
html {
-webkit-writing-mode: vertical-rl;
-epub-writing-mode: tb-rl;
writing-mode: vertical-rl;
}

#img-grid {
    padding: 0;
    display: grid;
    grid-template-rows: repeat(2, 1fr);
    grid-auto-columns: 45vw;
    gap: 2vw;
}

""" : """
#img-grid {
    padding: 0;
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    grid-auto-rows: 45vw;
    gap: 2vw;
}
""")

#img-in-page {
    aspect-ratio: 1;
    object-fit: cover;
}

.break-left {
    break-before: left;
}
""".data(using: .utf8)!
        
        //MARK: - Archive
        if FileManager.default.fileExists(atPath: destinationURL.path()) {
            try FileManager.default.removeItem(at: destinationURL)
        }
        
        guard let archive = Archive(url: destinationURL, accessMode: .create) else {
            throw ConvertError.failedToCreateFile(path: destinationURL.path())
        }
        
        let infoFiles: [String:Data] = [
            "mimetype": mimetypeData,
            "META-INF/container.xml": containerXMLData,
            "META-INF/com.apple.ibooks.display-options.xml": iBooksDisplayOptionsData,
            Templates.packageFilePath: packageFileData,
            "OEBPS/\(Templates.navFileName)": navFileData,
            "OEBPS/Styles/styles.css": cssFileData
        ]
        
        try infoFiles.forEach { (path, data) in
            try archive.addData(data, with: path)
        }
        
        for (index, article) in story.articles.enumerated() {
            let articleNumber = index + 1
            let path = "OEBPS/Texts/page\(articleNumber).xhtml"
            let data = pageXHTMLDataGenerator(articleNumber, article)
            try archive.addData(data, with: path)
        }
        
        for (articleIndex, article) in story.articles.enumerated() {
            for (photoIndex, photo) in article.photos.enumerated() {
                let name = "image\(articleIndex+1)-\(photoIndex+1)"
                let path = "OEBPS/Images/\(name).\(jpgTojpeg(photo.fileExtension))"
                try archive.addData(photo.data, with: path)
            }
        }
        
        return
    }
    
    private func jpgTojpeg(_ string: String) -> String {
        if string == "jpg" {
            return "jpeg"
        }
        return string
    }

    private func modifyStringForXHTML(_ string: String) -> String {
        var result = string
        
        let escapeMap: [String:String] = [
            "&": "&amp;",
            "<": "&lt;",
            ">": "&gt;",
            "\"": "&quot;",
            "'": "&apos;"
        ]
        
        for (symbol, escaped) in escapeMap {
            result = result.replacingOccurrences(of: symbol, with: escaped)
        }
        
        return result
    }
}
