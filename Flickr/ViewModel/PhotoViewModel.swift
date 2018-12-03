//
//  PhotoViewModel.swift
//  Flickr
//
//  Created by Badarinath Venkatnarayansetty on 12/1/18.
//  Copyright © 2018 Badarinath Venkatnarayansetty. All rights reserved.
//

import Foundation

class PhotoListViewModel {
    
    private(set) var photoViewModels = [PhotoViewModel]()
    
    typealias Handler = (Bool) -> ()
    var service:Service
    var completion:Handler
    var query:String?
    
    init(service: Service, query: String = "", completion : @escaping Handler ) {
        self.service = service
        self.completion = completion
        self.query = query
        fetchData(query: query)
    }
    
    private func fetchData(query: String) {
        service.fetchPhotoData(query: query) { (photos) in
            switch photos {
                case .success(let photos) :
                        self.photoViewModels = photos.map(PhotoViewModel.init)
                        self.completion(true)
                case .failure(let error) :
                        print("Error \(error)")
                        self.completion(false)
            }
        }
    }
}

class PhotoViewModel {
    var photo:Photo
    
    init(photo: Photo) {
        self.photo = photo
    }
}

