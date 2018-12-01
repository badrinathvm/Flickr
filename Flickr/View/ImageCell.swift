//
//  ImageCell.swift
//  Flickr
//
//  Created by Badarinath Venkatnarayansetty on 12/1/18.
//  Copyright © 2018 Badarinath Venkatnarayansetty. All rights reserved.
//

import Foundation
import UIKit

class ImageCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var mainImage: UIImageView = { [unowned self] in
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private func setup() {
        
        self.contentView.addSubview(mainImage)
        
        NSLayoutConstraint.activate([
            self.mainImage.topAnchor.constraint(equalTo: topAnchor,constant: 5),
            self.mainImage.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 5),
            self.mainImage.trailingAnchor.constraint(equalTo: trailingAnchor,constant: -5),
            self.mainImage.bottomAnchor.constraint(equalTo: bottomAnchor,constant: -5)
        ])
    }
    
    //to avoid flickering effect when scrolling of the tableview.
    override func prepareForReuse() {
        mainImage.image = nil
    }
}

