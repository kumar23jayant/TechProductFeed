//
//  FeedPresenter.swift
//  Sprinklr
//
//  Created by B0206635 on 05/12/20.
//  Copyright (c) 2020 B0206635. All rights reserved.
//

import UIKit

// MARK: Feed Presentation Logic

protocol FeedPresentationLogic
{
    func presentFetchedProducts(response: Feed.FetchProducts.Response)
    func presentFetchedFilters(response: Feed.FetchFilters.Response)
    func presentFilteredProducts(response: Feed.FilterProducts.Response)
    func presentBookmarkedProducts(response: Feed.FetchBookmarks.Response)
}


// MARK: Feed Presenter

class FeedPresenter {
 
    weak var viewController: FeedDisplayLogic?
    
    
    /* Creates view model isntance using model data.*/
    
    private func getViewModel(from model: Product) -> DisplayProduct {
        return DisplayProduct(id: model.id, title: model.title, description: model.description, imageUrl: model.imageUrl, founderProfile: model.founderProfile, type: model.type, isBookmarked: model.isBookmarked, upvoteCount: model.upvoteCount)
    }
}


// MARK: Presentation logic

extension FeedPresenter: FeedPresentationLogic {
  
    func presentFetchedProducts(response: Feed.FetchProducts.Response) {
        let displayedProducts = response.product.map { product in
            return getViewModel(from: product)
        }

        let viewModel = Feed.FetchProducts.ViewModel(displayProduct: displayedProducts)
        viewController?.displayFetchedProducts(viewModel: viewModel)
    }

    func presentFetchedFilters(response: Feed.FetchFilters.Response) {
        let viewModel = Feed.FetchFilters.ViewModel(displayFilters: response.filters, lastFilter: response.lastFilter)
        viewController?.displayFetchedFilters(viewModel: viewModel)
    }

    func presentFilteredProducts(response: Feed.FilterProducts.Response) {

        let displayFilteredProducts = response.product.map { product in
            return getViewModel(from: product)
        }

        let viewModel = Feed.FilterProducts.ViewModel(displayProduct: displayFilteredProducts)
        viewController?.displayFilteredProducts(viewModel: viewModel)
    }

    func presentBookmarkedProducts(response: Feed.FetchBookmarks.Response) {

        let displayFilteredProducts = response.bookmarkedProducts.map { product in
            return getViewModel(from: product)
        }

        let viewModel = Feed.FetchBookmarks.ViewModel(displayBookmarkedProducts: displayFilteredProducts)
        viewController?.displayBookmarkedProducts(viewModel: viewModel)
    }
}
