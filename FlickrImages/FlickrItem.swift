//
//  FlickrItem.swift
//  FlickrImages
//
//  Created by Joffrey Mann on 2/15/24.
//

import Foundation

class Root: Codable {
    var items: [FlickrItem]
}

class FlickrItem: Codable, Identifiable, Equatable {
    static func == (lhs: FlickrItem, rhs: FlickrItem) -> Bool {
        return lhs.title == rhs.title
    }
    
    enum FlickrItemKeys: String, CodingKey {
        case title
        case link
        case media
        case dateTaken = "date_taken"
        case description
        case published
        case author
        case authorID = "author_id"
        case tags
    }
    
    let title: String
    let link: String
    let media: Media
    let dateTaken: String
    let description: String
    let published: String
    let author: String
    let authorID: String
    let tags: String
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: FlickrItemKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.link = try container.decode(String.self, forKey: .link)
        self.media = try container.decode(Media.self, forKey: .media)
        self.dateTaken = try container.decode(String.self, forKey: .dateTaken)
        self.description = try container.decode(String.self, forKey: .description)
        self.published = try container.decode(String.self, forKey: .published)
        self.author = try container.decode(String.self, forKey: .author)
        self.authorID = try container.decode(String.self, forKey: .authorID)
        self.tags = try container.decode(String.self, forKey: .tags)
    }
}

struct Media: Codable {
    let m: String
}

//private func result() -> LoadFeedResult {
//    let expectation = expectation(description: "Wait for completion")
//    let testServerURL = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
//    let client = URLSessionHTTPClient()
//    let loader = RemoteFeedLoader(url: testServerURL, client: client)
//    
//    var receivedResult: LoadFeedResult!
//    loader.load { result in
//        receivedResult = result
//        expectation.fulfill()
//    }
//    wait(for: [expectation], timeout: 5)
//    return receivedResult
//}
