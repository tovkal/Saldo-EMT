//
//  BusLineCollectionViewController.swift
//  SaldoEMT
//
//  Created by Andrés Pizá on 27/9/15.
//  Copyright © 2015 tovkal. All rights reserved.
//

import UIKit

private let identifier = "BusLine"

class BusLineCollectionViewController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var busLines = [BusLine]()
        
    override func awakeFromNib() {
        self.busLines = Store.sharedInstance.getBusLinesForFare(Store.sharedInstance.getSelectedFare())
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView!.registerClass(BusLineView.self, forCellWithReuseIdentifier: identifier)
    }
}

// MARK: UICollectionViewDataSource

extension BusLineCollectionViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return busLines.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! BusLineView
        
        cell.populateWithBusLine(busLines[indexPath.row])
        
        return cell
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension BusLineCollectionViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
//        
//        // Center bus line bubbles horizontally
//        let edgeInsets = (self.view.frame.width - (CGFloat(busLines.count) * 50) - (CGFloat(busLines.count) * 10)) / 2
//        return UIEdgeInsetsMake(0, edgeInsets, 0, 0);
//    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(40, 40)
    }
    
}
