//
//  ViewController.swift
//  News
//
//  Created by aya on 29/04/2024.
//

import UIKit
import CoreData
import Reachability

class ViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource {
    
    
    var newsItems: [NewsItem] = []

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let newsItem = newsItems[indexPath.row]
                (cell.contentView.viewWithTag(2) as! UILabel).text = newsItem.author
                
                if let imageUrl = URL(string: newsItem.imageURL) {
                    (cell.contentView.viewWithTag(1) as! UIImageView).sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "girl"))
                }
        return cell
    }
    
    func fetchNewsItems() {
        newsItems.removeAll()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "News")
        
        do {
            let fetchedNewsItems = try context.fetch(fetchRequest)
            for fetchedNewsItem in fetchedNewsItems {
                guard let author = fetchedNewsItem.value(forKey: "author") as? String,
                      let title = fetchedNewsItem.value(forKey: "title") as? String,
                      let description = fetchedNewsItem.value(forKey: "desription") as? String,
                      let publishedAt = fetchedNewsItem.value(forKey: "publishedAt") as?
                        String,
                      
                      let imageURL = fetchedNewsItem.value(forKey: "imageURL") as? String else {
                    continue
                }
                let newsItem = NewsItem(author: author, title: title, desription: description, imageURL: imageURL, url: "url", publishedAt: publishedAt)
                newsItems.append(newsItem)
                print("description\(newsItems.description)")

            }
            print("Data fetched")
            tableView.reloadData()
        } catch let error {
            print("Error fetching news items: \(error.localizedDescription)")
        }
    }

    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let newsItemToDelete = newsItems[indexPath.row]
            
            let alertController = UIAlertController(title: "Delete News", message: "Are you sure you want to delete this news?", preferredStyle: .alert)
    
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                self.newsItems.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "News")
                fetchRequest.predicate = NSPredicate(format: "author = %@", newsItemToDelete.author)
                
                do {
                    if let result = try context.fetch(fetchRequest) as? [NSManagedObject] {
                        for object in result {
                            context.delete(object)
                        }
                        try context.save()
                        print("News item deleted from database")
                    }
                } catch {
                    print("Failed to delete news item from database: \(error)")
                }
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        }
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newsItem = newsItems[indexPath.item]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newsDetailsVC = storyboard.instantiateViewController(withIdentifier: "NewsDetailViewController") as! StaticTableViewController
        newsDetailsVC.selectedNewsItem = newsItem
        navigationController?.pushViewController(newsDetailsVC, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidAppear(_ animated: Bool) {
        fetchNewsItems()

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

//        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
//               backgroundImage.image = UIImage(named: "1")
//
//        backgroundImage.contentMode = UIView.ContentMode.center
//
//               self.view.insertSubview(backgroundImage, at: 0)
        
    }


}

