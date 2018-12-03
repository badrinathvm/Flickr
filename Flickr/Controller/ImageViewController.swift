//
//  ImageViewController.swift
//  Flickr
//
//  Created by Badarinath Venkatnarayansetty on 12/1/18.
//  Copyright © 2018 Badarinath Venkatnarayansetty. All rights reserved.
//

import Foundation
import UIKit

class ImageViewController: UIViewController {
    
    private var viewModel:PhotoViewModel?
    private var imageData: Data?
    
    //This initilazer to collect view model to render the image.
    init(viewModel: PhotoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    //This initilazer is to collect imageData during offline mode.
    init?(imageData: Data) {
         self.imageData = imageData
         super.init(nibName: nil, bundle: nil)
    }
    
    private lazy var mainImage: UIImageView = { [unowned self] in
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    // this is required to align the image view in landscape mode avoiding to re draw it again.
    private lazy var topImageContainer:UIView = { [unowned self] in
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        setupImageView()
    }
    
    private func setupImageView() {
        
        self.view.addSubview(topImageContainer)
        topImageContainer.addSubview(mainImage)
        
        if Reachability.isConnectedToNetwork() {
             guard let photo = viewModel?.photo else { return }
             self.mainImage.loadImage(for: photo.server, id: photo.id, secret: photo.secret, sizeParam: true)
        }else {
            guard let imageData = imageData else { return }
            self.mainImage.image = UIImage(data: imageData)
        }
       
        //Set constraints for image Container to handle display of image both in landscape/portrait modes.
        NSLayoutConstraint.activate([
            topImageContainer.heightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.5),
            topImageContainer.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 50),
            topImageContainer.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            topImageContainer.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
        ])
        
        //Set up constraints for imageview
        NSLayoutConstraint.activate([
            mainImage.centerXAnchor.constraint(equalTo: topImageContainer.centerXAnchor),
            mainImage.centerYAnchor.constraint(equalTo: topImageContainer.centerYAnchor),
            mainImage.leadingAnchor.constraint(equalTo: topImageContainer.leadingAnchor),
            mainImage.trailingAnchor.constraint(equalTo: topImageContainer.trailingAnchor),
            mainImage.heightAnchor.constraint(equalTo: topImageContainer.heightAnchor, multiplier: 1.0)
        ])
    }
}

