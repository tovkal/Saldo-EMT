//
//  LineViewController.swift
//  SaldoEMT
//
//  Created by Andrés Pizá Bückmann on 10/10/15.
//  Copyright © 2015 tovkal. All rights reserved.
//

import UIKit

private let identifier = "FareCell"

class FaresViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private var busLines = [BusLine(number: "1", color: UIColor.redColor(), name: "test", fares: [Fare(name: "tal", cost: 1.0, days: nil, rides: nil)])]
    private var contentViewControllers: [BusLineCollectionViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(UINib(nibName: "FareCell", bundle: nil), forCellReuseIdentifier: identifier)
        //tableView.registerClass(FareCell.self, forCellReuseIdentifier: identifier)
        tableView.estimatedRowHeight = 150;
        tableView.rowHeight = UITableViewAutomaticDimension;
        
        for _ in 1...10 {
            let busLineCollectionViewController = storyboard!.instantiateViewControllerWithIdentifier("BusLineCollectionViewController") as! BusLineCollectionViewController
            self.addChildViewController(busLineCollectionViewController)
            contentViewControllers.append(busLineCollectionViewController)
        }
    }
    @IBAction func didCancelFareSelection(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension FaresViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(150)
    }
}

extension FaresViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! FareCell
        
        //cell.fareName.text = "Potato"
        //cell.busLinesCollectionView = storyboard!.instantiateViewControllerWithIdentifier("BusLineCollectionViewController") as! BusLineCollectionViewController
        //cell.setCollectionViewDataSourceDelegate(dataSourceDelegate: BusLineCollectionViewController(), index: indexPath.row)
        
        let busLineCollection = contentViewControllers[indexPath.row] //storyboard!.instantiateViewControllerWithIdentifier("BusLineCollectionViewController") as! BusLineCollectionViewController
/*        if busLineCollection.view != nil {
            cell.contentView.addSubview(busLineCollection.view)
        }*/
        if busLineCollection.view != nil && cell.busLinesView != nil {
            cell.busLinesView.addSubview(busLineCollection.view)
        }
        /*
        if cell.busLinesCollectionView == nil {
        print("cell view nil")
        }
        if busLineCollection.view == nil {
        print("buslinecoll view nil")
        }
        //busLineCollection.collectionView.frame = cell.busLinesCollectionView.bounds
        //busLineCollection.collectionView = UICollectionView
        cell.busLinesCollectionView.addSubview(busLineCollection.view)
        
        */
        
        /*
        cell.busLinesCollectionView = UIView()
        busLineCollection.collectionView = cell.busLinesCollectionView*/
        
        // Configure the cell...
        
        return cell
    }
}