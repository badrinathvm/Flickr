//
//  Extensions+Additions.swift
//  Flickr
//
//  Created by Badarinath Venkatnarayansetty on 12/1/18.
//  Copyright © 2018 Badarinath Venkatnarayansetty. All rights reserved.
//

import Foundation
import UIKit

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
        
        print(url)
        
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
                }
            }
        }
        task.resume()
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


