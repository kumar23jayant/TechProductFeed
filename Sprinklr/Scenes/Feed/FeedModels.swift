//
//  FeedModels.swift
//  Sprinklr
//
//  Created by B0206635 on 05/12/20.
//  Copyright (c) 2020 B0206635. All rights reserved.
//

import UIKit

// Model
struct Product: Codable {
    
    var id: Int
    var title: String
    var description: String
    var imageUrl: String?
    var founderProfile: String?
    var type: ProductTypes
    var isBookmarked: Bool? = false
    var upvoteCount: Int
}

enum ProductTypes: String, Codable {
    
    case trending = "Trending"
    case machineLearning = "Machine Learning"
    case edTech = "EdTech"
    case medical = "Medical"
}


// View Model
struct DisplayProduct {
    var id: Int
    var title: String
    var description: String
    var imageUrl: String?
    var founderProfile: String?
    var type: ProductTypes
    var isBookmarked: Bool? = false
    var upvoteCount: Int
}


// Feed namespace
enum Feed
{
    enum FetchProducts {
        
        struct Request { }
        struct Response {
            struct ResponseModel: Codable {
                var all: [Product]
            }

            var product: [Product]
        }
        struct ViewModel {
            var displayProduct: [DisplayProduct]
        }
    }
    
    enum FilterProducts {
        
        struct Request {
            var filterType: String
        }
        struct Response {
            var product: [Product]
        }
        struct ViewModel {
            var displayProduct: [DisplayProduct]
        }
    }
    
    enum BookmarkProduct {
        
        struct Request {
            var productId: Int
        }
        struct Response { }
        struct ViewModel { }
    }
    
    enum FetchBookmarks {
        
        struct Request { }
        struct Response {
            var bookmarkedProducts: [Product]
        }
        struct ViewModel {
            var displayBookmarkedProducts: [DisplayProduct]
        }
    }
    
    enum UpvoteProduct {
        
        struct Request {
            var productId: Int
        }
        struct Response {
            var product: [Product]
        }
        struct ViewModel {
            var displayProduct: [DisplayProduct]
        }
    }
    
    enum FetchFilters {
        struct Request { }
        struct Response {
            var filters: [String]
            var lastFilter: String
        }
        struct ViewModel {
            var displayFilters: [String]
            var lastFilter: String
        }
    }
}


struct KeyConstants {
    static let bookmark = "bookmarkedProducts"
    static let lastFilter = "lastFilter"
}
