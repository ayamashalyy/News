//
//  StaticTableViewController.swift
//  News
//
//  Created by aya on 03/05/2024.
//

import UIKit
import CoreData


class StaticTableViewController: UITableViewController {
    var selectedNewsItem: NewsItem?
    var isFavorite: Bool = false
    
    @IBOutlet weak var autherLable: UILabel!
    @IBOutlet weak var newsImages: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var publishLable: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isFavorite = isNewsItemInDatabase()
        
        updateFavoriteButtonImage()
        
        if let newsItem = selectedNewsItem {
            titleLable.text = newsItem.title
            autherLable.text = newsItem.author
            descriptionText.text = newsItem.desription
            publishLable.text = newsItem.publishedAt
            if let imageUrl = URL(string: newsItem.imageURL) {
                newsImages.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "1"))
            }
        }
    }
    
    func isNewsItemInDatabase() -> Bool {
        guard let newsItem = selectedNewsItem else {
            return false
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "News")
        fetchRequest.predicate = NSPredicate(format: "title = %@", newsItem.title)
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Error checking if news item exists in database: \(error.localizedDescription)")
            return false
        }
    }
    
    @IBAction func saveFavorites(_ sender: UIBarButtonItem) {
        if isFavorite {
            showDeleteConfirmationAlert()
        } else {
            saveNewsItemToDatabase()
            isFavorite = true
        }
        updateFavoriteButtonImage()
    }
    
    func saveNewsItemToDatabase() {
        guard let newsItem = selectedNewsItem else {
            return
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "News", in: context)
        let newsManagedObject = NSManagedObject(entity: entity!, insertInto: context)
        
        newsManagedObject.setValue(newsItem.author, forKey: "author")
        newsManagedObject.setValue(newsItem.imageURL, forKey: "imageURL")
        newsManagedObject.setValue(newsItem.desription, forKey: "desription")
        newsManagedObject.setValue(newsItem.title, forKey: "title")
        newsManagedObject.setValue(newsItem.publishedAt, forKey: "publishedAt")
        
        do {
            try context.save()
            print("News item saved to database")
        } catch {
            print("Error saving news item to database: \(error.localizedDescription)")
        }
    }
    
    func showDeleteConfirmationAlert() {
        let alert = UIAlertController(title: "Delete Favorite", message: "Are you sure you want to delete this news item from favorites?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.deleteNewsItemFromDatabase()
            self.isFavorite = false
            self.updateFavoriteButtonImage()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func deleteNewsItemFromDatabase() {
        guard let newsItem = selectedNewsItem else {
            return
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "News")
        fetchRequest.predicate = NSPredicate(format: "title = %@", newsItem.title)
        
        do {
            let objects = try context.fetch(fetchRequest)
            for object in objects {
                context.delete(object as! NSManagedObject)
            }
            try context.save()
            print("News item deleted from database")
        } catch {
            print("Error deleting news item from database: \(error.localizedDescription)")
        }
    }
    
    func updateFavoriteButtonImage() {
        let buttonImageName = isFavorite ? "3" : "2"
        let button = UIBarButtonItem(image: UIImage(named: buttonImageName), style: .plain, target: self, action: #selector(saveFavorites(_:)))
        navigationItem.rightBarButtonItem = button
    }
}


