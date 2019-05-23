//
//  ListViewController.swift
//  Cool Card
//
//  Created by Kou Barlow on 5/22/19.
//  Copyright © 2019 Kou Barlow. All rights reserved.
//

import UIKit

class ListViewController: UICollectionViewController {

    let coolCellId = "coolCell"
    
    let coolItems = [
        CoolItem(color: #colorLiteral(red: 1, green: 0.2555361697, blue: 0.1961229018, alpha: 1), title: "Red", details: "I am red."),
        CoolItem(color: #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1), title: "Green", details: "I am green."),
        CoolItem(color: #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1), title: "Blue", details: "I am blue."),
        CoolItem(color: #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), title: "Yellow", details: "I am yellow.")
    ]
    
    private var isStatusBarHidden = false
    
    private var coolCell: CoolCell?
    private var hiddenCells: [CoolCell] = []
    
    private var animator: UIViewPropertyAnimator?
    
    override var prefersStatusBarHidden: Bool {
        return isStatusBarHidden
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = .white
        self.collectionView.backgroundColor = .white
        collectionView.register(CoolCell.self, forCellWithReuseIdentifier: coolCellId)
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return coolItems.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: coolCellId, for: indexPath) as! CoolCell
        let coolItem = coolItems[indexPath.row]
        cell.configureCell(color: coolItem.color, title: coolItem.title, details: coolItem.details)
        return cell
    }
    
    // Animations start here! ⛳️
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        /* 💔💔💔 NOT SURE WHAT THIS DOES BUT IT DOESN'T LET THIS COOL ANIMATION WORK 💔💔💔
         
        if collectionView.contentOffset.y < 0 || collectionView.contentOffset.y > collectionView.contentSize.height - collectionView.frame.height {
            return
        }
         
        */
        
        let dampingRatio: CGFloat = 0.8
        let initialVelocity = CGVector.zero
        let springParameters = UISpringTimingParameters(dampingRatio: dampingRatio, initialVelocity: initialVelocity)
        animator = UIViewPropertyAnimator(duration: 0.5, timingParameters: springParameters)
        
        guard let animator = animator else { return }

        if let selectedCell = coolCell {
            collapseCells(selectedCell: selectedCell, animator: animator)
        } else {
            expandCell(indexPath: indexPath, animator: animator)
        }
        
        animator.addAnimations {
            self.setNeedsStatusBarAppearanceUpdate()
        }
        animator.startAnimation()
    }
    
    private func collapseCells(selectedCell: CoolCell, animator: UIViewPropertyAnimator) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        isStatusBarHidden = false
        
        animator.addAnimations {
            selectedCell.collapse()
            
            for cell in self.hiddenCells {
                cell.show()
            }
        }
        
        animator.addCompletion { (_) in
            self.coolCell = nil
            self.hiddenCells.removeAll()
            
            self.collectionView.isScrollEnabled = true
        }
    }
    
    private func expandCell(indexPath: IndexPath, animator: UIViewPropertyAnimator) {
        navigationController?.setNavigationBarHidden(true, animated: true)
        isStatusBarHidden = true
        
        let selectedCell = collectionView.cellForItem(at: indexPath) as! CoolCell
        let selectedCellFrame = selectedCell.frame
        hiddenCells = collectionView.visibleCells.map { $0 as! CoolCell }.filter { $0 != selectedCell }
        
        animator.addAnimations {
            selectedCell.expand(in: self.collectionView)
            
            for cell in self.hiddenCells {
                cell.hide(in: self.collectionView, fromFrame: selectedCellFrame)
            }
        }
        
        coolCell = selectedCell
        
        collectionView.isScrollEnabled = false
    }
}

extension ListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let availableWidth = collectionView.bounds.insetBy(dx: collectionView.layoutMargins.left, dy: collectionView.layoutMargins.top * 2).size.width
        
        let minColumnWidth = CGFloat(256)
        let maxNumColumns = Int(availableWidth / minColumnWidth)
        let cellWidth = (availableWidth / CGFloat(maxNumColumns)).rounded(.down)
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets(top: layout.minimumInteritemSpacing, left: 0, bottom: 0, right: 0)
        layout.sectionInsetReference = .fromSafeArea
        
        return CGSize(width: cellWidth, height: 50)
    }
    
    /* ⛳️ Why not: willTransitionToNewCollection? It doesn't work on iPad. So use this: */
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if let selectedCell = coolCell {
            selectedCell.collapse()
            
            navigationController?.setNavigationBarHidden(false, animated: true)
            isStatusBarHidden = false
            
            self.coolCell = nil
            self.hiddenCells.removeAll()
            
            self.collectionView.isScrollEnabled = true
        }
        self.collectionView?.collectionViewLayout.invalidateLayout()
    }
}
