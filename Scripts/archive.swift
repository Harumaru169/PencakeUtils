#!/usr/bin/swift
import Foundation

let fm = FileManager.default

/*
 
 fm.temporaryDirectory
 ├──tempDirectory
 │   ├── binaryDirectory
 │   │   └── executable
 │   ├── license
 │   └── installScript
 │
 ├── executableName.zip
 │
 
 */

//MARK: - Paths
let executablePath = CommandLine.arguments[1]
let executableName = URL(fileURLWithPath: executablePath).lastPathComponent

let tempDirectoryPath = "\(fm.temporaryDirectory.path)/\(executableName)"
let tempDirectoryName = URL(fileURLWithPath: tempDirectoryPath).lastPathComponent

let binaryDirectoryPath = "\(tempDirectoryPath)/bin"

let zipFileName = "\(executableName).zip"

let installScriptPath = "Scripts/install.sh"
let installScriptName = URL(fileURLWithPath: installScriptPath).lastPathComponent

let licensePath = "LICENSE"
let licenseName = URL(fileURLWithPath: licensePath, isDirectory: false).lastPathComponent

let archiveDirectoryPath = ".build/archive/"

let currentDirectoryPath = fm.currentDirectoryPath

//MARK: - Check that the file exists.
for path in [executablePath, installScriptPath, licensePath] {
    guard fm.fileExists(atPath: path) else {
        let absoluteString = URL(fileURLWithPath: path).absoluteString
        fatalError("File Does Not Exist: \(absoluteString)")
    }
}

//MARK: - Just in case, remove the directory created in the previous run.
if fm.fileExists(atPath: tempDirectoryPath) {
    try fm.removeItem(atPath: tempDirectoryPath)
}

//MARK: - Copy
try fm.createDirectory(atPath: binaryDirectoryPath, withIntermediateDirectories: true)
try fm.copyItem(atPath: executablePath, toPath: "\(binaryDirectoryPath)/\(executableName)")
try fm.copyItem(atPath: installScriptPath, toPath: "\(tempDirectoryPath)/\(installScriptName)")
try fm.copyItem(atPath: licensePath, toPath: "\(tempDirectoryPath)/\(licenseName)")

//MARK: - Zip
fm.changeCurrentDirectoryPath("\(tempDirectoryPath)/..")

let zipNameWithoutExtension = zipFileName.replacingOccurrences(of: ".zip", with: "")
let zip = Process()
zip.executableURL = URL(fileURLWithPath: "/usr/bin/zip")
zip.arguments = ["-r", zipNameWithoutExtension, tempDirectoryName, "-x", "*.DS_Store"]
zip.launch()
zip.waitUntilExit()

fm.changeCurrentDirectoryPath(currentDirectoryPath)

//MARK: - Move zip file to .build/archive/
let zipFilePath = URL(fileURLWithPath: tempDirectoryPath)
    .deletingLastPathComponent()
    .appendingPathComponent(zipFileName)
    .path
let zipFileDestinationPath = "\(archiveDirectoryPath)/\(zipFileName)"
try fm.createDirectory(atPath: archiveDirectoryPath, withIntermediateDirectories: true)
if fm.fileExists(atPath: zipFileDestinationPath) {
    try fm.removeItem(atPath: zipFileDestinationPath)
}
try fm.moveItem(atPath: zipFilePath, toPath: zipFileDestinationPath)

//MARK: - Cleanup
try fm.removeItem(atPath: tempDirectoryPath)
