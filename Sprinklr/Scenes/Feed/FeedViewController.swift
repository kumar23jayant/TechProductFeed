//
//  FeedViewController.swift
//  Sprinklr
//
//  Created by B0206635 on 05/12/20.
//  Copyright (c) 2020 B0206635. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialChips


// MARK: Feed Display Logic

protocol FeedDisplayLogic: class {
    
    func displayFetchedProducts(viewModel: Feed.FetchProducts.ViewModel)
    func displayFetchedFilters(viewModel: Feed.FetchFilters.ViewModel)
    func displayFilteredProducts(viewModel: Feed.FilterProducts.ViewModel)
    func displayBookmarkedProducts(viewModel: Feed.FetchBookmarks.ViewModel)
}


// MARK: Feed View Controller

class FeedViewController: UIViewController
{
    var interactor: FeedBusinessLogic?
    var displayedProducts: [DisplayProduct] = []
    var filter: [String] = []
    var lastFilter: String = ""
    
    
    // MARK: IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filterView: MDCChipView!
    @IBOutlet weak var filterCollectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var filterCollectionView: UICollectionView!
    

    // MARK: Object lifecycle
  
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        setup()
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupTableView()
        setupFilterView()
        fetchProducts()
        fetchFilters()
        applyLastFilter()
    }
    
}


// MARK: Private Methods

extension FeedViewController {
  
    private func setup() {
        
        let viewController = self
        let interactor = FeedInteractor()
        let presenter = FeedPresenter()
        
        viewController.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = viewController
    }

    private func setupFilterView() {
        
        let flowLayout = MDCChipCollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.estimatedItemSize = CGSize(width: 40.0, height: 10.0)
        
        filterCollectionView.collectionViewLayout = flowLayout
        filterCollectionView.register(MDCChipCollectionViewCell.self, forCellWithReuseIdentifier: FeedConstants.filterCellReuseIdentifier)
    }
    
    private func setupTableView() {
        
        tableView.estimatedRowHeight = 100
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: FeedConstants.feedCellNibName, bundle: nil), forCellReuseIdentifier: FeedConstants.feedCellReuseIdentifier)
    }
  
    private func fetchProducts() {
        
        let request = Feed.FetchProducts.Request()
        interactor?.fetchProduct(request: request)
    }
    
    private func fetchFilters() {
        
      let request = Feed.FetchFilters.Request()
      interactor?.fetchFilters(request: request)
    }
    
    private func applyLastFilter() {
        
        interactor?.applyLastFilter()
    }
    
    private func updateTableData(with products: [DisplayProduct]) {
        
        displayedProducts = products
        tableView.reloadData()
    }
  
}


// MARK: Presenter Delegate

extension FeedViewController: FeedDisplayLogic {
    
    func displayFilteredProducts(viewModel: Feed.FilterProducts.ViewModel) {
        updateTableData(with: viewModel.displayProduct)
    }
    
    func displayFetchedFilters(viewModel: Feed.FetchFilters.ViewModel) {
        filter = viewModel.displayFilters
        lastFilter = viewModel.lastFilter
        filterCollectionView.reloadData()
        guard let index = filter.firstIndex(of: lastFilter) else {
            return
        }
        let indexPath = IndexPath(row: index, section: 0)
        filterCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .left)
    }
    
    func displayFetchedProducts(viewModel: Feed.FetchProducts.ViewModel) {
        
        updateTableData(with: viewModel.displayProduct)
    }
    
    func displayBookmarkedProducts(viewModel: Feed.FetchBookmarks.ViewModel) {
        updateTableData(with: viewModel.displayBookmarkedProducts)
    }
}


// MARK: Table Data Source

extension FeedViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedProducts.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FeedConstants.feedCellReuseIdentifier, for: indexPath) as? FeedProductTableViewCell else {
            return UITableViewCell()
        }
        
        let data = displayedProducts[indexPath.row]
        cell.prepareCell(with: data)
        cell.delegate = self
        cell.indexPath = indexPath
        return cell
    }
}


// MARK: Collection View Data Source

extension FeedViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filter.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeedConstants.filterCellReuseIdentifier, for: indexPath) as? MDCChipCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let chipView = cell.chipView
        
        chipView.titleLabel.text = filter[indexPath.row]
        chipView.setTitleColor(UIColor.blue, for: .selected)
        
        return cell
    }
}


// MARK: CollectionView flow layout delegate

extension FeedViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let request = Feed.FilterProducts.Request(filterType: filter[indexPath.row])
        interactor?.filterProducts(request: request)
    }
}


// MARK: Feed Product TableViewCell Delegate

extension FeedViewController: FeedProductTableViewCellDelegate {
    
    func openShareSheet(title: String) {
        let vc = UIActivityViewController(activityItems: [title], applicationActivities: [])
        present(vc, animated: true, completion: nil)
    }
    
    func bookmarkProduct(with index: Int) {
        let request = Feed.BookmarkProduct.Request(productId: displayedProducts[index].id)
        interactor?.bookmarkProduct(request: request)
    }
    
    func upvote(for index: Int) {
        let request = Feed.UpvoteProduct.Request(productId: displayedProducts[index].id)
        interactor?.upvoteProduct(request: request)
    }
}


// MARK: String Constants

struct FeedConstants {
    static let feedCellNibName = "FeedProductTableViewCell"
    static let feedCellReuseIdentifier = "FeedProductTableViewCell"
    static let filterCellReuseIdentifier = "FilterCell"
}
