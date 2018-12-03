//
//  ViewController.swift
//  Flickr
//
//  Created by Badarinath Venkatnarayansetty on 12/1/18.
//  Copyright © 2018 Badarinath Venkatnarayansetty. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController {
    
    fileprivate let reuseIdentifier = "imageCell"
    private var photoListViewModel: PhotoListViewModel?
    private var datasource:GenericDataSource<PhotoViewModel>?
    private var photoDataSource: GenericDataSource<Data>?
    
    var photoManagedObject = [NSManagedObject]()
    
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
    
    private lazy var searchBar: UISearchBar = { [unowned self] in
        let searchBarView = UISearchBar()
        searchBarView.translatesAutoresizingMaskIntoConstraints = false
        searchBarView.delegate = self
        return searchBarView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        setupTableView()
        
        setupActivityIndicator()
        
        setupSearchBar()
        
        setupNavigationBar()
        
        if Reachability.isConnectedToNetwork() {
            //Clear the existing core data to store fresh results.
            clearCoreData()
            displayPhotoList()
        }else {
            fetchFromLocalStorage()
        }
        
        //listen to observer for search results.
        NotificationCenter.default.addObserver(self, selector: #selector(searchResults), name: .search, object: nil)
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
    
    private func setupSearchBar() {
        self.view.addSubview(searchBar)
        navigationItem.titleView = searchBar
        searchBar.showsScopeBar = false
        searchBar.placeholder = "Search"
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.topItem?.title = "Photos"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
    }
    
    private func displayPhotoList(from search: Bool = false) {
        photoListViewModel = PhotoListViewModel(service: Service(), completion: { status in
          if status {
                guard let viewModels = self.photoListViewModel?.photoViewModels else { return }
                self.datasource = GenericDataSource.make(for: viewModels, reuseIdentifier: self.reuseIdentifier)
                self.tableView.dataSource = self.datasource
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
            }else if !search {
                self.displayAlert { (status) in
                    if status {
                        self.activityIndicator.stopAnimating()
                    }
                }
            }
        })
    }
    
    //This method fetches the data from Core Data,
    //if results are empty displays an alert else renders the content in tableView.
    private func fetchFromLocalStorage() {
        let dataArray = readFromCoreData()
        guard dataArray.count > 0 else {
            displayAlert { (status) in
                if status {
                    self.activityIndicator.stopAnimating()
                }
            }
            return
        }
        
        //then reloads the table view data
        self.photoDataSource = GenericDataSource.make(for: dataArray, reuseIdentifier: self.reuseIdentifier)
        self.tableView.dataSource = self.photoDataSource
        self.tableView.reloadData()
        self.activityIndicator.stopAnimating()
    }
    
    @objc func searchResults(notification: Notification) {
        guard let query = notification.userInfo?["query"] as? String else { return }
        photoListViewModel = PhotoListViewModel(service: Service(), query: query, completion: { status in
            if status {
                guard let viewModels = self.photoListViewModel?.photoViewModels else { return }
                self.datasource = GenericDataSource.make(for: viewModels, reuseIdentifier: self.reuseIdentifier)
                self.tableView.dataSource = self.datasource
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
            }else {
                self.displayAlert(message: "The Internet connection appears to be offline") { dismiss in
                    if dismiss {
                        self.activityIndicator.stopAnimating()
                    }
                }
            }
        })
    }
}


//MARK: Handle tableView  height and , did select row updates and it's respective navigations.

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //handle scenario for offline mode.
        guard Reachability.isConnectedToNetwork() else {
            let dataArray = readFromCoreData()
            let photoVC = ImageViewController.init(imageData: dataArray[indexPath.row])
            self.navigationController?.pushViewController(photoVC!, animated: true)
            return
        }
        
        guard let viewModel = photoListViewModel?.photoViewModels[indexPath.row] else { return }
        let photoVC = ImageViewController.init(viewModel: viewModel)
        self.navigationController?.pushViewController(photoVC, animated: true)
    }
}

//MARK: Rendering the cells contents with images

extension GenericDataSource where Items == PhotoViewModel {
    static func make(for items: [Items], reuseIdentifier: String ) -> GenericDataSource {
        let dataSource = GenericDataSource(items: items, reuseIdentifier: reuseIdentifier) { (cell, viewModel) in
            let _cell = cell as! ImageCell
            _cell.mainImage.loadImage(for: viewModel.photo.server, id: viewModel.photo.id, secret: viewModel.photo.secret)
        }
        return dataSource
    }
}


//MARK: This gets executed when there is no cell / wifi network , renders the images from CoreData.

extension GenericDataSource where Items == Data {
    static func make(for items: [Items], reuseIdentifier: String ) -> GenericDataSource {
        let dataSource = GenericDataSource(items: items, reuseIdentifier: reuseIdentifier) { (cell, viewModel) in
            let _cell = cell as! ImageCell
            _cell.mainImage.image = UIImage(data: viewModel)
        }
        return dataSource
    }
}

//MARK: This is for the search delegates methods for firing a call to flickr api based on the query submitted for eg: bus
// if search query is cleared , it resets the table view to original data.
// dismiss of keyboard on dragging, press of x icon on search bar etc..

extension HomeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            //resetting to the original results
            displayPhotoList(from: true)
            
            //dismiss keyboard
            searchBar.perform(#selector(self.resignFirstResponder), with: nil, afterDelay: 0.1)
            return
        }
        
        //post a notification to display the search results.
        NotificationCenter.default.post(name: .search, object: nil, userInfo: ["query": searchText] )
    }
    
    //dismiss keyboard on click of search button in keyboard
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    //dismiss keyboard on scrolling 
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
}
