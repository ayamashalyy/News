//
//  NewsCollectionViewController.swift
//  News
//
//  Created by aya on 29/04/2024.
//

import UIKit
import SDWebImage
import  Reachability
import CoreData

protocol HomeProtocol : AnyObject{
    func renderTableView()
}


class NewsCollectionViewController: UICollectionViewController ,UICollectionViewDelegateFlowLayout,HomeProtocol{
    
    var presenter : HomePresenter!
    var newsItems: [NewsItem] = []
    var network : Reachability!
    var indicator = UIActivityIndicatorView().self
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActivityIndicator()
        setupReachability()
        presenter = HomePresenter()
        fetchNewsAPi()

    }
    private func setupActivityIndicator() {
            indicator = UIActivityIndicatorView(style: .large)
            indicator.center = view.center
            indicator.startAnimating()
            view.addSubview(indicator)
        }
  
    private func setupReachability() {
           network = try! Reachability()
           NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: .reachabilityChanged, object: network)
           do {
               try network.startNotifier()
           } catch {
               print("Unable to start reachability notifier")
           }
       }
    
    private func fetchNewsAPi() {
        presenter?.attachView(view: self)
        presenter?.getNews()
        
        }
    
    private func fetchNewsFromCoreData() {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }

            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Home")

            do {
                let result = try managedContext.fetch(fetchRequest)
                if let newsItemEntities = result as? [NSManagedObject] {
                    var coreDataNewsItems: [NewsItem] = []
                    for newsItemEntity in newsItemEntities {
                        guard let author = newsItemEntity.value(forKey: "author") as? String,
                              let title = newsItemEntity.value(forKey: "title") as? String,
                                let url = newsItemEntity.value(forKey: "url") as? String,
                              let desription = newsItemEntity.value(forKey: "desription") as? String,
                              let publishedAt = newsItemEntity.value(forKey: "publishedAt") as? String,
                              let imageURL = newsItemEntity.value(forKey: "imageURL") as? String
                        else {
                            continue
                        }
                        let newsItem = NewsItem(author: author, title: title, desription: desription, imageURL: imageURL, url: url, publishedAt: publishedAt)
                        coreDataNewsItems.append(newsItem)
                    }
                    if !coreDataNewsItems.isEmpty {
                        self.newsItems = coreDataNewsItems
                        self.collectionView.reloadData()
                    }
                }
            } catch let error as NSError {
                print("Could not fetch from Core Data. \(error), \(error.userInfo)")
            }
        }

    
    @objc private func reachabilityChanged() {
          guard let reachability = network else { return }
          if reachability.connection != .unavailable {
              if newsItems.isEmpty {
                  fetchNewsFromCoreData()
              } else {
                  fetchNewsAPi()              }
          }
      }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return newsItems.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        
        var newsItem = presenter.news?[indexPath.item]
        cell.myLable.text = newsItem?.author
        if let imageUrl = URL(string: newsItem!.imageURL) {
               cell.myImage.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "girl"))
           }
                
                return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width / 2.1, height: view.frame.width / 2)
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let newsItem = newsItems[indexPath.item]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newsDetailsVC = storyboard.instantiateViewController(withIdentifier: "NewsDetailViewController") as! StaticTableViewController
        newsDetailsVC.selectedNewsItem = newsItem
        navigationController?.pushViewController(newsDetailsVC, animated: true)
    }

}

extension NewsCollectionViewController{
    func renderTableView(){
        self.newsItems = presenter.news!
        self.indicator.stopAnimating()
        self.collectionView.reloadData()
    }
}
