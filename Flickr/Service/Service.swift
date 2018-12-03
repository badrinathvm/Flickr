//
//  Service.swift
//  Flickr
//
//  Created by Badarinath Venkatnarayansetty on 12/1/18.
//  Copyright © 2018 Badarinath Venkatnarayansetty. All rights reserved.
//

import Foundation

enum Result<Photo> {
    case success(Photo)
    case failure(Error)
}

class Service {
    
    var endPoint:String?
    
    func fetchPhotoData(query: String = "" , completion :  @escaping (Result<[Photo]>) -> ()) {
        print(query.count)
        
        let apiKey = "675894853ae8ec6c242fa4c077bcf4a0"
        endPoint = query.count == 0 ? "https://api.flickr.com/services/rest/?method=flickr.photos.getRecent&per_page=500&api_key=\(apiKey)&format=json&nojsoncallback=true" :
        "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=675894853ae8ec6c242fa4c077bcf4a0&text=\(query)&per_page=500&extras=url_s&format=json&nojsoncallback=1"
        
        guard let url = URL.init(string: endPoint!) else { return }
        
        let session  = URLSession.init(configuration: URLSessionConfiguration.default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else if let jsonData = data {
                    do {
                        let decoder = JSONDecoder()
                        let photos = try decoder.decode(PhotoData.self, from: jsonData).photos.photo
                        completion(.success(photos))
                    }catch let error {
                        completion(.failure(error))
                    }
                }else {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Data was not retrieved from request"]) as Error
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}



