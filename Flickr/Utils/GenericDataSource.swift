//
//  GenericDataSource.swift
//  Flickr
//
//  Created by Badarinath Venkatnarayansetty on 12/1/18.
//  Copyright © 2018 Badarinath Venkatnarayansetty. All rights reserved.
//

import Foundation
import UIKit

class GenericDataSource<Items>: NSObject, UITableViewDataSource {
    
    typealias CellConfig = (UITableViewCell, Items) -> ()
    
    var items:[Items]
    var reuseIdentifier:String
    var cellConfig:CellConfig
    
    init(items: [Items] , reuseIdentifier: String, cellConfig: @escaping CellConfig) {
        self.items = items
        self.reuseIdentifier = reuseIdentifier
        self.cellConfig = cellConfig
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cellConfig(cell, item)
        return cell
    }
}


