//
//  FeedWorker.swift
//  Sprinklr
//
//  Created by B0206635 on 05/12/20.
//  Copyright (c) 2020 B0206635. All rights reserved.
//

import UIKit

// MARK: Network Worker
//
// Worker for Fetching products

class NetworkWorker
{
    private func fetchDummyProducts() -> [Product] {
        
        if let filepath = Bundle.main.path(forResource: "model", ofType: "json") {
            do {
                let contents = try String(contentsOfFile: filepath)
                let data = contents.data(using: .utf8)
                
                let products = try JSONDecoder().decode(Feed.FetchProducts.Response.ResponseModel.self, from: data!)
                
                return products.all
            } catch {
                return []
            }
        } else {
            print("File not found")
        }
        
        return []
    }
    
    
    /* Fetching data from mock file while it can be replaced with Network call any time.*/
    func fetchProducts(completionHandler: @escaping ([Product]) -> Void) {
        
        completionHandler(fetchDummyProducts())
    }
    
    func fetchFilter(completionHandler: ([String]) -> Void) {
        
        completionHandler(["All", "EdTech", "Medical", "Machine Learning", "Trending", "Bookmarks"])
    }
}



// MARK: Persistant Worker
//
// Worker for persistant storage

class PersistantWorker {
    
    func bookmarkProduct(with product: Product) {
        
        var bookmarkedProducts = fetchBookmarkProducts()
        bookmarkedProducts.append(product)
        
        if let encodeObject = try? JSONEncoder().encode(bookmarkedProducts) {
            UserDefaults.standard.set(encodeObject, forKey: KeyConstants.bookmark)
        }
    }
    
    func updateBookmarkProduct(with product: Product) {
        do {
            
            guard let encodedProducts = UserDefaults.standard.object(forKey: KeyConstants.bookmark) as? Data else {
                return
            }
            
            var products = try JSONDecoder().decode([Product].self, from: encodedProducts)
            
            products = products.map { item in
                if item.id == product.id {
                    return product
                }
                else {
                    return item
                }
            }
            
            if let encodeObject = try? JSONEncoder().encode(products) {
                UserDefaults.standard.set(encodeObject, forKey: KeyConstants.bookmark)
            }
            
        }catch { }
        
        return
    }
    
    func removeBookmarkProduct(with id: Int) {
        do {
            
            guard let encodedProducts = UserDefaults.standard.object(forKey: KeyConstants.bookmark) as? Data else {
                return
            }
            
            var products = try JSONDecoder().decode([Product].self, from: encodedProducts)
            
            products = products.filter { $0.id != id }
            
            if let encodeObject = try? JSONEncoder().encode(products) {
                UserDefaults.standard.set(encodeObject, forKey: KeyConstants.bookmark)
            }
            
        }catch { }
        
        return
    }
    
    func fetchBookmarkProducts() -> [Product] {
        do {
            
            guard let encodedProducts = UserDefaults.standard.object(forKey: KeyConstants.bookmark) as? Data else {
                return []
            }
            
            let products = try JSONDecoder().decode([Product].self, from: encodedProducts)
            
            return products
        }catch {
            
        }
        
        return []
    }
    
    func getValue(for key: String) -> String? {
        return UserDefaults.standard.value(forKey: key) as? String
    }
    
    func setValue(_ value: String, for key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }

}
