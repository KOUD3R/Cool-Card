//
//  CoolCell.swift
//  Cool Card
//
//  Created by Kou Barlow on 5/22/19.
//  Copyright © 2019 Kou Barlow. All rights reserved.
//

import UIKit

struct CoolItem {
    var color: UIColor
    var title: String
    var details: String
}

class CoolCell: UICollectionViewCell {
    
    var initialFrame: CGRect?
    var initialCornerRadius: CGFloat?
    
    var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpLayout()
    }
    
    func configureCell(color: UIColor, title: String, details: String) {
        backgroundColor = color
    }
    
    private func setUpLayout() {
        layer.cornerRadius = 12
        layer.masksToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CoolCell {
    // Animations start here! ⛳️
    func expand(in collectionView: UICollectionView) {
        initialFrame = self.frame
        initialCornerRadius = self.contentView.layer.cornerRadius
        
        self.contentView.layer.cornerRadius = 0
        self.frame = CGRect(x: 0, y: collectionView.contentOffset.y, width: screenWidth, height: screenHeight)
        
        layoutIfNeeded()
    }
    
    func collapse() {
        self.contentView.layer.cornerRadius = initialCornerRadius ?? self.contentView.layer.cornerRadius
        self.frame = initialFrame ?? self.frame
        
        initialFrame = nil
        initialCornerRadius = nil
        
        layoutIfNeeded()
    }
    
    func show() {
        self.frame = initialFrame ?? self.frame
        
        initialFrame = nil
        
        layoutIfNeeded()
    }
    
    func hide(in collectionView: UICollectionView, fromFrame: CGRect) {
        initialFrame = self.frame
        
        let currentY = self.frame.origin.y
        let newY: CGFloat
        
        if currentY < fromFrame.origin.y {
            let offset = fromFrame.origin.y - currentY
            newY = collectionView.contentOffset.y - offset
        } else {
            let offset = currentY - fromFrame.maxY
            newY = collectionView.contentOffset.y + screenHeight + offset
        }
        
        self.frame.origin.y = newY
        
        layoutIfNeeded()
    }
}
