//
//  LikeButton.swift
//  Animations Demo
//
//  Created by Jayant Kumar Yadav on 5/12/20.
//

import UIKit

class AnimatableButton: UIButton {
  
    private var isLiked = false {
        didSet{
            if isLiked {
                setImage(likedImage, for: .normal)
            }else {
                setImage(unlikedImage, for: .normal)
            }
        }
    }
  
    private let unlikedImage = UIImage(named: "bookmark_empty")
    private let likedImage = UIImage(named: "bookmark_filled")

    private let unlikedScale: CGFloat = 0.8
    private let likedScale: CGFloat = 1.1

    public func flipLikedState() {
        isLiked = !isLiked
        animate()
    }
    
    public func setSelection(state selected: Bool, with animation: Bool = false) {
        isLiked = selected
        if animation { animate() }
    }

    private func animate() {
        UIView.animate(withDuration: 0.1, animations: {
                let newImage = self.isLiked ? self.likedImage : self.unlikedImage
                let newScale = self.isLiked ? self.likedScale : self.unlikedScale
                self.transform = self.transform.scaledBy(x: newScale, y: newScale)
                self.setImage(newImage, for: .normal)
            }, completion: { _ in
                UIView.animate(withDuration: 0.1, animations: {
                self.transform = CGAffineTransform.identity
            })
        })
    }
}
