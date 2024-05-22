//
//  NetworkManager.swift
//  News
//
//  Created by aya on 14/05/2024.
//

import Foundation

func fetchNews(handler: @escaping ([NewsItem]) -> Void) {
    guard let url = URL(string: "https://raw.githubusercontent.com/DevTides/NewsApi/master/news.json")
    else {
        return
    }
    let request = URLRequest(url: url)
    let session = URLSession(configuration: .default)

    let task = session.dataTask(with: request) {(data, response, error) in
        guard let data = data else {
            print("No data received")
            return
        }
        
        do {
            let results = try JSONDecoder().decode([NewsItem].self, from: data)
            print("Successfully decoded news items:", results)
            handler(results)
        } catch let decodingError {
            print("Error decoding news JSON:", decodingError.localizedDescription)
        }
    }
    task.resume()
}
