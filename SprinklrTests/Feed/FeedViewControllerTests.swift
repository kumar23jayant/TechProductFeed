//
//  FeedViewControllerTests.swift
//  SprinklrTests
//
//  Created by B0206635 on 06/12/20.
//  Copyright © 2020 B0206635. All rights reserved.
//


@testable import Sprinklr
import XCTest

class FeedViewControllerTests: XCTestCase
{
  // MARK: - Subject under test
  
  var sut: FeedViewController!
  var window: UIWindow!
  
  // MARK: - Test lifecycle
  
  override func setUp()
  {
    super.setUp()
    window = UIWindow()
    setupFeedViewController()
  }
  
  override func tearDown()
  {
    window = nil
    super.tearDown()
  }
  
  // MARK: - Test setup
  
  func setupFeedViewController()
  {
    let bundle = Bundle.main
    let storyboard = UIStoryboard(name: "Main", bundle: bundle)
    sut = storyboard.instantiateViewController(withIdentifier: "FeedViewController") as? FeedViewController
  }
  
  func loadView()
  {
    window.addSubview(sut.view)
    RunLoop.current.run(until: Date())
  }
  
  // MARK: - Test doubles
  
  class FeedBusinessLogicSpy: FeedBusinessLogic
  {
    
    

    
    func fetchFilters(request: Feed.FetchFilters.Request) {
        
    }
    
    func filterProducts(request: Feed.FilterProducts.Request) {
        
    }
    
    func applyLastFilter() {
        
    }
    
    func bookmarkProduct(request: Feed.BookmarkProduct.Request) {
        
    }
    
    func upvoteProduct(request: Feed.UpvoteProduct.Request) {
        
    }
    
    var products: [Product]?
    
    // MARK: Method call expectations
    
    var fetchProductsCalled = false
    
    // MARK: Spied methods

    func fetchProduct(request: Feed.FetchProducts.Request) {
        fetchProductsCalled = true
    }
    
  }
  
  class TableViewSpy: UITableView
  {
    // MARK: Method call expectations
    
    var reloadDataCalled = false
    
    // MARK: Spied methods
    
    override func reloadData()
    {
      reloadDataCalled = true
    }
  }
  
  // MARK: - Tests
  
  func testShouldFetchOrdersWhenViewDidAppear()
  {
    // Given
    let feedBusinessLogicSpy = FeedBusinessLogicSpy()
    sut.interactor = feedBusinessLogicSpy
    loadView()
    
    // When
    sut.viewDidLoad()
    
    // Then
    XCTAssert(feedBusinessLogicSpy.fetchProductsCalled, "Should fetch products right after the view appears")
  }
  
  func testShouldDisplayFetchedOrders()
  {
    // Given
    let tableViewSpy = TableViewSpy()
    sut.tableView = tableViewSpy
    
    // When
    let displayedProducts = FeedProductsMock.shared.getDisplayProducts()
    let viewModel = Feed.FetchProducts.ViewModel(displayProduct: displayedProducts)
    sut.displayFetchedProducts(viewModel: viewModel)
    
    // Then
    XCTAssert(tableViewSpy.reloadDataCalled, "Displaying fetched products should reload the table view")
  }
  
  func testNumberOfSectionsInTableViewShouldAlwaysBeOne()
  {
    // Given
    let tableView = sut.tableView
    
    // When
    let numberOfSections = sut.numberOfSections(in: tableView!)
    
    // Then
    XCTAssertEqual(numberOfSections, 1, "The number of table view sections should always be 1")
  }
  
  func testNumberOfRowsInAnySectionShouldEqaulNumberOfOrdersToDisplay()
  {
    // Given
    let tableView = sut.tableView
    sut.displayedProducts = FeedProductsMock.shared.getDisplayProducts()
    
    // When
    let numberOfRows = sut.tableView(tableView!, numberOfRowsInSection: 0)
    
    // Then
    XCTAssertEqual(numberOfRows, FeedProductsMock.shared.products.count, "The number of table view rows should equal the number of orders to display")
  }
  
  func testShouldConfigureTableViewCellToDisplayOrder()
  {
    // Given
    let tableView = sut.tableView
    sut.displayedProducts = FeedProductsMock.shared.getDisplayProducts()
    
    // When
    let indexPath = IndexPath(row: 0, section: 0)
    let cell = sut.tableView(tableView!, cellForRowAt: indexPath) as! FeedProductTableViewCell
    
    // Then
    XCTAssertEqual(cell.title.text, sut.displayedProducts[0].title, "A properly configured table view cell should display the product title")
    XCTAssertEqual(cell.subtitle.text, sut.displayedProducts[0].description, "A properly configured table view cell should display the product subtitle")
    XCTAssertEqual(cell.upvoteCount.text, "\(sut.displayedProducts[0].upvoteCount)", "A properly configured table view cell should display the product upvote count")
  }
}


final class FeedProductsMock
{
    static let shared = FeedProductsMock()
    var products: [Product] = []
    
    private init() {
        products = fetchDummyProducts()
    }
    
    func fetchDummyProducts() -> [Product] {
        
        if let filepath = Bundle.main.path(forResource: "model", ofType: "json") {
            do {
                let contents = try String(contentsOfFile: filepath)
                let data = contents.data(using: .utf8)
                
                let products = try JSONDecoder().decode(Feed.FetchProducts.Response.ResponseModel.self, from: data!)
                
                return products.all
            } catch {
                // contents could not be loaded
                return []
            }
        } else {
            print("File not found")
        }
        
        return []
    }
    
    func fetchFilter(completionHandler: @escaping ([String]) -> Void) {
        completionHandler(["All", "EdTech", "Medical", "Machine Learning", "Trending", "Bookmarks"])
    }
    
    func getDisplayProducts() -> [DisplayProduct] {
        return products.map { product in
            
            return DisplayProduct(id: product.id, title: product.title, description: product.description, imageUrl: product.imageUrl, founderProfile: product.founderProfile, type: product.type, isBookmarked: product.isBookmarked, upvoteCount: product.upvoteCount)
            
        }
    }
}
