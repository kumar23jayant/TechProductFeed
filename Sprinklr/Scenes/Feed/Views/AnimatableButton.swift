//
//  AnimatableButton.swift
//  Sprinklr
//
//  Created by B0206635 on 05/12/20.
//  Copyright © 2020 B0206635. All rights reserved.
//

import UIKit


// MARK: Constants

struct AnimatableButtonConstants {
    static let selectedImage = "bookmark_filled"
    static let deselectedImage = "bookmark_empty"
}


// MARK: Animatable Button
//
// This UIButton subclass is used to provide an animation
// of scale in/out on button click.


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
  
    private let unlikedImage = UIImage(named: AnimatableButtonConstants.deselectedImage)
    private let likedImage = UIImage(named: AnimatableButtonConstants.selectedImage)

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
