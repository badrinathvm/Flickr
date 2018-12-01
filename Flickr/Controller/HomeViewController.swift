//
//  ViewController.swift
//  Flickr
//
//  Created by Badarinath Venkatnarayansetty on 12/1/18.
//  Copyright © 2018 Badarinath Venkatnarayansetty. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    fileprivate let reuseIdentifier = "imageCell"
    
    private var photoListViewModel: PhotoListViewModel?
    
    private var datasource:GenericDataSource<PhotoViewModel>?
    
    private lazy var tableView:UITableView = { [unowned self] in
          let table = UITableView()
          table.translatesAutoresizingMaskIntoConstraints = false
          table.delegate = self
          table.register(ImageCell.self, forCellReuseIdentifier: self.reuseIdentifier)
          return table
    }()
    
    private lazy var activityIndicator:UIActivityIndicatorView = { [unowned self] in
        let indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = .white
        
        setupTableView()
        
        setupActivityIndicator()
        
        displayPhotoList()
    }
    
    private func setupTableView() {
        self.view.addSubview(tableView)
        
        tableView.estimatedSectionHeaderHeight = 50
        tableView.rowHeight = UITableView.automaticDimension
        
        //setting constraints for tableview
        NSLayoutConstraint.activate([
         self.tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
         self.tableView.leadingAnchor.constraint(equalTo:self.view.safeAreaLayoutGuide.leadingAnchor),
         self.tableView.trailingAnchor.constraint(equalTo:self.view.safeAreaLayoutGuide.trailingAnchor),
         self.tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupActivityIndicator() {
        self.tableView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        //setting constraints for activity Indicator
        NSLayoutConstraint.activate([
            self.activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.activityIndicator.widthAnchor.constraint(equalToConstant: 50),
            self.activityIndicator.heightAnchor.constraint(equalTo: self.activityIndicator.widthAnchor)
        ])
    }
    
    private func displayPhotoList() {
        photoListViewModel = PhotoListViewModel(service: Service(), completion: {
            guard let viewModels = self.photoListViewModel?.photoViewModels else { return }
            self.datasource = GenericDataSource.make(for: viewModels, reuseIdentifier: self.reuseIdentifier)
            self.tableView.dataSource = self.datasource
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
        })
    }
}


extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
}

extension GenericDataSource where Items == PhotoViewModel {
    static func make(for items: [Items], reuseIdentifier: String ) -> GenericDataSource {
        let dataSource = GenericDataSource(items: items, reuseIdentifier: reuseIdentifier) { (cell, viewModel) in
            let _cell = cell as! ImageCell
            _cell.mainImage.loadImage(for: viewModel.photo.server, id: viewModel.photo.id, secret: viewModel.photo.secret)
        }
        return dataSource
    }
}
