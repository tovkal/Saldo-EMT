//
//  BusLineCollectionViewController.swift
//  SaldoEMT
//
//  Created by Andrés Pizá on 27/9/15.
//  Copyright © 2015 tovkal. All rights reserved.
//

import UIKit

class BusLineCollectionViewController: UICollectionViewController {
    
    private let reuseIdentifier = "BusLine"
    
    private var busLines = [BusLine(number: "1", color: UIColor.redColor(), name: "test", fares: [Fare(name: "tal", cost: 1.0, days: nil, rides: nil)])]/*,
                            BusLine(number: "2", color: UIColor.yellowColor()),
                            BusLine(number: "3", color: UIColor.blueColor())]*/

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView!.registerClass(BusLineView.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
}

// MARK: UICollectionViewDataSource

extension BusLineCollectionViewController {
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return busLines.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! BusLineView
        
        cell.busLine.text = busLines[indexPath.row].number
        cell.backgroundColor = busLines[indexPath.row].color
        
        return cell
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension BusLineCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        
        // Center bus line bubbles horizontally
        let edgeInsets = (self.view.frame.width - (CGFloat(busLines.count) * 50) - (CGFloat(busLines.count) * 10)) / 2
        return UIEdgeInsetsMake(0, edgeInsets, 0, 0);
    }
}
