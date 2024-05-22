//
//  NewsItem.swift
//  News
//
//  Created by aya on 29/04/2024.
//

import Foundation

struct NewsItem: Codable {
        let author, title, desription: String
        let imageURL: String
        let url: String
        let publishedAt: String

        enum CodingKeys: String, CodingKey {
            case author, title, desription
            case imageURL = "imageUrl"
            case url, publishedAt
        }
    }



