//
//  HomePresenter.swift
//  News
//
//  Created by aya on 14/05/2024.
//

import Foundation


class HomePresenter{
    var news : [NewsItem]?
    weak var view : HomeProtocol?
    func attachView(view : HomeProtocol){
            self.view = view
        }
    func getNews(){
        fetchNews(handler: ) {[weak self] news in
            self?.news = news
            DispatchQueue.main.async {
                self?.view?.renderTableView()
                
            }
        }
    }
}
