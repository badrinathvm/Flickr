//
//  Photo.swift
//  Flickr
//
//  Created by Badarinath Venkatnarayansetty on 12/1/18.
//  Copyright © 2018 Badarinath Venkatnarayansetty. All rights reserved.
//

import Foundation

struct PhotoData: Codable {
    var photos: Photos
}

struct Photos: Codable {
    var photo:[Photo]
}

struct Photo: Codable {
    var id:String
    var owner:String
    var secret:String
    var server:String
    var farm:Int
    var title:String
    var isPublic:Int
    var isFriend:Int
    var isFamily:Int
    var urls:String
    var height:String
    var width:String
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case owner = "owner"
        case secret = "secret"
        case server = "server"
        case farm = "farm"
        case title = "title"
        case isPublic = "ispublic"
        case isFriend = "isfriend"
        case isFamily = "isfamily"
        case urls = "url_s"
        case height = "height_s"
        case width = "width_s"
    }
    
    init(id:String,owner:String, secret:String, server:String, farm:Int, title:String, isPublic: Int, isFriend: Int , isFamily:Int, urls:String, height: String, width: String) {
        self.id = id
        self.owner = owner
        self.secret = secret
        self.server = server
        self.farm = farm
        self.title = title
        self.isPublic = isPublic
        self.isFriend  = isFriend
        self.isFamily = isFamily
        self.urls = urls
        self.height = height
        self.width = width
    }
    
    //map the keys according to desired value types.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        owner = try container.decode(String.self, forKey: .owner)
        secret = try container.decode(String.self, forKey: .secret)
        server = try container.decode(String.self, forKey: .server)
        farm = try container.decode(Int.self, forKey: .farm)
        title = try container.decode(String.self, forKey: .title)
        isPublic = try container.decode(Int.self, forKey: .isPublic)
        isFriend = try container.decode(Int.self, forKey: .isFriend)
        isFamily = try container.decode(Int.self, forKey: .isFamily)
        urls = try container.decode(String.self, forKey: .urls)
        height = try container.decode(String.self, forKey: .height)
        width = try container.decode(String.self, forKey: .width)
    }
}
