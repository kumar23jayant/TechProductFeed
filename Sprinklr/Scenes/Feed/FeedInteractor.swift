//
//  FeedInteractor.swift
//  Sprinklr
//
//  Created by B0206635 on 05/12/20.
//  Copyright (c) 2020 B0206635. All rights reserved.
//

import UIKit

// MARK: Feed Business Logic

protocol FeedBusinessLogic {
    
    func fetchProduct(request: Feed.FetchProducts.Request)
    func fetchFilters(request: Feed.FetchFilters.Request)
    func filterProducts(request: Feed.FilterProducts.Request)
    func applyLastFilter()
    func bookmarkProduct(request: Feed.BookmarkProduct.Request)
    func upvoteProduct(request: Feed.UpvoteProduct.Request)
}


// MARK: Feed Interactor

class FeedInteractor {
    
    var presenter: FeedPresentationLogic?
    lazy var worker = NetworkWorker()
    lazy var persistantWorker = PersistantWorker()
    var products: [Product]?
    
    var selectedFilter: String = FilterConstants.all {
        didSet {
            persistantWorker.setValue(selectedFilter, for: KeyConstants.lastFilter)
        }
    }
  
    
    /* Returns all bookmarked products saved in store. */
    private func fetchBookmarkedProducts() {
        
        var bookmarkedProducts = persistantWorker.fetchBookmarkProducts()
        
        bookmarkedProducts = bookmarkedProducts.map { bookmarkedProduct in
            
            var item = bookmarkedProduct
            if let index = products?.firstIndex(where: { $0.id == bookmarkedProduct.id }) {
                let product = products?[index]
                item.upvoteCount = product?.upvoteCount ?? 0
            }
            return item
        }
        
        let response = Feed.FetchBookmarks.Response(bookmarkedProducts: bookmarkedProducts)
        self.presenter?.presentBookmarkedProducts(response: response)
    }
    
    
    /* Merge bookmark status in current products. */
    private func updateBookmarkedProducts() {
        
        let bookmarkedProducts = persistantWorker.fetchBookmarkProducts()
        
        var bookmarkedProductIds: Set<Int> = []
        
        bookmarkedProducts.forEach { bookmarkedProductIds.insert($0.id) }
        
        let updatedProducts = products?.map { product -> Product in
            var temp = product
            if bookmarkedProductIds.contains(temp.id) { temp.isBookmarked = true }
            else { temp.isBookmarked = false }
            return temp
        }
        
        self.products = updatedProducts
    }
    
    
    /* Gets last selected filter from store. */
    private func fetchLastSelectedFilter() {
        if let lastSelectedFilter = persistantWorker.getValue(for: KeyConstants.lastFilter) {
            selectedFilter = lastSelectedFilter
        }
    }
    
    
    /* Applies filter and present filtered data. */
    func applyFilter() {
        
        if selectedFilter == FilterConstants.all {
            self.updateBookmarkedProducts()
            let response = Feed.FilterProducts.Response(product: products ?? [])
            self.presenter?.presentFilteredProducts(response: response)
            return
        }
        
        if selectedFilter == FilterConstants.bookmark {
            fetchBookmarkedProducts()
            return
        }
        
        self.updateBookmarkedProducts()
        
        guard let type = ProductTypes.init(rawValue: selectedFilter), let filteredProducts = products?.filter({ $0.type == type }) else {
            return
        }
        
        let response = Feed.FilterProducts.Response(product: filteredProducts)
        self.presenter?.presentFilteredProducts(response: response)
    }
    
}



// MARK: Extension Feed Business Logic

extension FeedInteractor: FeedBusinessLogic {
  
    func fetchProduct(request: Feed.FetchProducts.Request) {
        worker.fetchProducts { products in
            self.products = products
            
            self.updateBookmarkedProducts()
            
            let response = Feed.FetchProducts.Response(product: products)
            self.presenter?.presentFetchedProducts(response: response)
        }
    }
    
    func fetchFilters(request: Feed.FetchFilters.Request) {
        fetchLastSelectedFilter()
        worker.fetchFilter { filters in
            let response = Feed.FetchFilters.Response(filters: filters, lastFilter: self.selectedFilter)
            self.presenter?.presentFetchedFilters(response: response)
        }
    }
    
    func filterProducts(request: Feed.FilterProducts.Request) {
        
        self.selectedFilter = request.filterType
        applyFilter()
    }
    
    func bookmarkProduct(request: Feed.BookmarkProduct.Request) {
        
        let id = request.productId
        
        guard var product = products?.filter ({ $0.id == id }).first else {
            return
        }
        
        if let isBookmarked = product.isBookmarked, isBookmarked  {
            persistantWorker.removeBookmarkProduct(with: product.id)
        }
        else {
            product.isBookmarked = true
            persistantWorker.bookmarkProduct(with: product)
        }
        
        let request = Feed.FilterProducts.Request(filterType: self.selectedFilter)
        filterProducts(request: request)
        
    }
    
    func applyLastFilter() {
        applyFilter()
    }
    
    func upvoteProduct(request: Feed.UpvoteProduct.Request) {
        
        if selectedFilter == FilterConstants.bookmark { return }
        
        let id = request.productId
        
        guard var updatedProduct = products?.filter ({ $0.id == id }).first else {
            return
        }
        
        updatedProduct.upvoteCount += 1
        
        if let bookmarked = updatedProduct.isBookmarked, bookmarked {
            persistantWorker.updateBookmarkProduct(with: updatedProduct)
        }
        
        products = products?.map { product in
            if product.id == id {
                return updatedProduct
            }else {
                return product
            }
        }
        
        let request = Feed.FilterProducts.Request(filterType: self.selectedFilter)
        filterProducts(request: request)
    }
    
}



// MARK: Filter Constants

struct FilterConstants {
    static let all = "All"
    static let bookmark = "Bookmarks"
}
