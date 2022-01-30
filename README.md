# PencakeParser

`pencakeparser` is a CLI tool that converts [PenCake](https://apps.apple.com/jp/app/pencake-シンプルなノート-日記帳/id1382218014)'s articles or stories into a JSON format.

`PencakeParserCore` is a library for converting a story or an article to in-memory representation.

## Usage
### `pencakeparser` Command
```shell
$ pencakeparser story path_to_story_directory --language english --pretty-printed 
{
  "exportedDate" : 2022-01-19T07:44:27Z,
  "createdDate" : 2022-01-19T07:28:10Z,
  "title" : "My Story",
  "subtitle" : "Subtitle",
  "articles" : [
    ...
  ]
}

$ pencakeparser story path_to_story_directory -l english -p >> story.json

$ pencakeparser article path_to_article_file -l japanese >> Article_001.json
```
Run `pencakeparser --help` to show help information.

### `PencakeParserCore` Library
```swift
import PencakeParserCore

let storyURL = URL(fileURLWithPath: "path_to_story_directory")

let storyParser = StoryParser()

let options = ParseOptions(language: .english, newline: .lf)

let story = try await storyParser.parse(directoryURL: storyURL, options: options)

print("article count: \(story.articles.count)")

let jsonEncoder = JSONEncoder()
let jsonData = try jsonEncoder.encode(story)
print(String(data: jsonData, encoding: .utf8) ?? "nil")
```

## Installation

### `pencakeparser` Command
- From 'Releases', download the zip file and run:
```shell
$ chmod +x install.sh
$ ./install.sh
```
The script will copy the binary to`/usr/local/bin`.

- To build and install from source code, run `make install` in the project directory.

### `PencakeParserCore` Library
via SwiftPM:
```swift
dependencies: [
    .package(url: "https://github.com/Harumaru169/PencakeParser", from: "0.4.0")
]
```
