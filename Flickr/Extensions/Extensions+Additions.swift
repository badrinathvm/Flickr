//
//  Extensions+Additions.swift
//  Flickr
//
//  Created by Badarinath Venkatnarayansetty on 12/1/18.
//  Copyright © 2018 Badarinath Venkatnarayansetty. All rights reserved.
//

import Foundation
import UIKit
import CoreData

//MARK : for laying out properly on landscape mode.
extension UIView {
    var safeAreaFrame: CGRect {
        if #available(iOS 11, *) {
            return safeAreaLayoutGuide.layoutFrame
        }
        return bounds
    }
}

fileprivate let imageCache = NSCache<AnyObject,AnyObject>()

extension UIImageView {
    
    //sample url:  https://farm6.staticflickr.com/5623/30145975463_02b8452545.jpg
    func loadImage(for server: String, id:String, secret:String, sizeParam: Bool = false) {
        let url =  "https://farm6.staticflickr.com/" + "\(server)/" + "\(id)_\(secret).jpg"
        guard let endPoint = URL.init(string: url) else { return }
        
        if let imageToCache = imageCache.object(forKey: endPoint as AnyObject) as? UIImage  {
            self.image = imageToCache
            return
        }
        
        let task = URLSession.shared.dataTask(with: endPoint) { (data, response, error) in
            DispatchQueue.main.async {
                if let imageData = data {
                    self.contentMode = .scaleAspectFit
                    guard let imageToCache = UIImage(data: imageData as Data) else {
                        self.image = UIImage(named: "placeholder.png")!.scaleImageToSize(newSize: CGSize(width: 800, height: 400))
                        return
                    }
                    imageCache.setObject(imageToCache, forKey: url as AnyObject)
                    self.image = !sizeParam ? imageToCache.scaleImageToSize(newSize: CGSize(width: 800, height: 400)) : imageToCache
                    
                    //store it in Core Data
                    self.saveToCoreData(imageData: imageData)
                }
            }
        }
        task.resume()
    }
    
    
    func saveToCoreData(imageData: Data) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return  }
        let managedContext = appDelegate.persistentContainer.viewContext
        guard let imageEntity = NSEntityDescription.entity(forEntityName: "Images", in: managedContext) else  { return }
        let options = NSManagedObject(entity: imageEntity, insertInto: managedContext)
        options.setValue(imageData, forKey: "offline")
        do {
            try managedContext.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

// MARK: - Image Scaling.
extension UIImage {
    
    /* Scales an image to fit within a bounds with a size governed by the passed size. Also keeps the aspect ratio.
     // - parameter newSize: newSize the size of the bounds the image must fit within.
     // - returns: a new scaled image.*/
    func scaleImageToSize(newSize: CGSize) -> UIImage {
        var scaledImageRect = CGRect.zero
        
        let aspectWidth = newSize.width/size.width
        let aspectheight = newSize.height/size.height
        let aspectRatio = max(aspectWidth, aspectheight)
        
        scaledImageRect.size.width = size.width * aspectRatio;
        scaledImageRect.size.height = size.height * aspectRatio;
        scaledImageRect.origin.x = (newSize.width - scaledImageRect.size.width) / 2.0;
        scaledImageRect.origin.y = (newSize.height - scaledImageRect.size.height) / 2.0;
        
        UIGraphicsBeginImageContext(newSize)
        draw(in: scaledImageRect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
}

//MARK : Notitication Name
extension Notification.Name {
    static let search = Notification.Name(rawValue: "search")
}

extension UIViewController {
    
    func readFromCoreData() -> [Data] {
        var dataArray = [Data]()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Images")
        do{
            let fetchedResults = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            for data in fetchedResults {
                guard let imageData = data.value(forKey: "offline") as? Data else  { return [] }
                dataArray.append(imageData)
            }
        }catch let error {
            print(error.localizedDescription)
        }
        return dataArray
    }
    
    func clearCoreData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Images")
        do{
            let fetchedResults = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            for data in fetchedResults {
                managedContext.delete(data)
                try managedContext.save()
            }
        }catch let error {
            print(error.localizedDescription)
        }
        print("Existing Core Data Images removed successful")
    }
    
    
    func displayAlert(title : String = "Flickr" , message:String = "Not displaying Images? Try again later!!", _ done: @escaping (Bool)->()) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            switch action.style {
            case .default:
                print("default")
                done(true)
            case .cancel:
                  done(true)
            case .destructive:
                  done(true)
            }
        }))
        self.present(alertController, animated: true, completion: nil)
    }
}
