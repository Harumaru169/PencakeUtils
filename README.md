# PencakeParser

CLI tool that converts [PenCake](https://apps.apple.com/jp/app/pencake-シンプルなノート-日記帳/id1382218014)'s articles or stories into a JSON file.

`PencakeParserCore` is a library for converting stories to in-memory representation.

## Usage
### `pencakeparser` command
```shell
$ pencakeparser story path_to_story_directory --pretty-printed
{
  "exportedDate" : 662745042,
  "createdDate" : 595585385,
  "title" : "My Story",
  "subtitle" : "Subtitle",
  "articles" : [
    ...
  ]
}
```

### `PencakeParserCore`
```swift
import PencakeParserCore

Task {
    let storyURL = URL(fileURLWithPath: "path_to_story_directory")
    let story: Story = try await StoryParser.shared.parse(directoryURL: storyURL)
    
    print("article count: \(story.articles.count)")
    
    let jsonEncoder = JSONEncoder()
    let jsonData = try jsonEncoder.encode(story)
    print(String(data: jsonData, encoding: .utf8) ?? "nil")
}
```

## Installation
via SwiftPM
```swift
dependencies: [
    .package(url: "...", from: "0.0.1")
]
```
