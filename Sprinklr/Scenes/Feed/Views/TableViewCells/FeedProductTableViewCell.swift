//
//  FeedProductTableViewCell.swift
//  Sprinklr
//
//  Created by B0206635 on 05/12/20.
//  Copyright © 2020 B0206635. All rights reserved.
//

import UIKit

// MARK: Feed Product Table View Cell Delegate
//
// Exposes methods to be called on delegate stores in Cell.

protocol FeedProductTableViewCellDelegate: class {
    func openShareSheet(title: String)
    func bookmarkProduct(with index: Int)
    func upvote(for index: Int)
}


// MARK: Feed Product Table View Cell
//
// Cell for rendering each Tech Product.

class FeedProductTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var founderProfileImage: UIImageView!
    @IBOutlet weak var bookmarkButton: AnimatableButton!
    @IBOutlet weak var upvoteCount: UILabel!
    @IBOutlet weak var rootView: UIView!
    
    weak var delegate: FeedProductTableViewCellDelegate?
    var indexPath: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setRoundedCorner()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    /* Reset bookmark selection state on resue. */
    
    override func prepareForReuse() {
        bookmarkButton.setSelection(state: false)
    }
    
    
    /* Provide rounded courners to cell container view. */
    
    private func setRoundedCorner() {
        rootView.layer.cornerRadius = 10
        rootView.clipsToBounds = true
    }
    
    
    /* Populate cell with view model data. */

    func prepareCell(with data: DisplayProduct) {
        title.text = data.title
        subtitle.text = data.description
        productImage.loadImage(url: URL(string: data.imageUrl ?? ""))
        bookmarkButton.setSelection(state: data.isBookmarked ?? false)
        upvoteCount.text = "\(data.upvoteCount)"
    }

    
    @IBAction func upvoteClicked(_ sender: Any) {
        guard let index = indexPath?.row else {
            return
        }
        
        self.delegate?.upvote(for: index)
    }
    
    @IBAction func bookmarkClicked(_ sender: Any) {
        guard let index = indexPath?.row, let button = sender as? AnimatableButton else {
            return
        }
        
        button.flipLikedState()
        
        self.delegate?.bookmarkProduct(with: index)
    }
    
    @IBAction func shareClicked(_ sender: Any) {
        self.delegate?.openShareSheet(title: title.text ?? "")
    }
    
}
