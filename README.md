# PencakeUtils

`pencake` is a CLI tool that converts articles or stories of [PenCake app](https://apps.apple.com/jp/app/pencake-シンプルなノート-日記帳/id1382218014) into JSON format.

`PencakeParser` is a library for converting stories or articles into in-memory representations.

## Usage
### `pencake` Command
```shell
$ pencake story path_to_story_directory --pretty-printed 
{
  "exportedDate" : 2022-01-19T07:44:27Z,
  "createdDate" : 2022-01-19T07:28:10Z,
  "title" : "My Story",
  "subtitle" : "Subtitle",
  "articles" : [
    ...
  ]
}

$ pencake story path_to_story_zipfile -p >> story.json

$ pencake article path_to_article_file --language ja >> Article_001.json
```
Run `pencake --help` to show help information.

### `PencakeParser` Library
```swift
import PencakeParser

let storyURL = URL(fileURLWithPath: "path_to_story_directory")

let storyParser = ParallelStoryParser()

let options = ParseOptions(language: .english, newline: .lf)

let story = try await storyParser.parse(directoryURL: storyURL, options: options)

print("article count: \(story.articles.count)")

let jsonEncoder = JSONEncoder()
let jsonData = try jsonEncoder.encode(story)
print(String(data: jsonData, encoding: .utf8) ?? "nil")
```

## Installation

### `pencake` Command
Download source code and run `make install` in the project directory.

### Package Dependency
via SwiftPM:
```swift
dependencies: [
    .package(url: "https://github.com/Harumaru169/PencakeUtils", from: "0.7.0")
]
```
