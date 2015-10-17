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
    
    var busLines = [BusLine(number: "1", color: UIColor.redColor(), name: "test", fares: [Fare(name: "tal", cost: 1.0, days: nil, rides: nil)]),
                            BusLine(number: "2", color: UIColor.yellowColor(), name: "test", fares: [Fare(name: "tal", cost: 1.0, days: nil, rides: nil)]),
                            BusLine(number: "3", color: UIColor.blueColor(), name: "test", fares: [Fare(name: "tal", cost: 1.0, days: nil, rides: nil)])]
    
    convenience init(busLines: [BusLine]) {
        self.init()
        
        self.busLines = busLines
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
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        
        // Center bus line bubbles horizontally
        let edgeInsets = (self.view.frame.width - (CGFloat(busLines.count) * 50) - (CGFloat(busLines.count) * 10)) / 2
        return UIEdgeInsetsMake(0, edgeInsets, 0, 0);
    }
}
