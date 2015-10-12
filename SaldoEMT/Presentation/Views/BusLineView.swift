//
//  BusLineView.swift
//  SaldoEMT
//
//  Created by Andrés Pizá on 27/9/15.
//  Copyright © 2015 tovkal. All rights reserved.
//

import UIKit

@IBDesignable
class BusLineView: UICollectionViewCell {
    
    var view: UIView!
    @IBOutlet weak var busLine: UILabel!
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    init(frame: CGRect, color: UIColor, lineNumber: String) {
        
        super.init(frame: frame)
        
        xibSetup()
        
        viewSetup()
    }
    
    /**
    Frame init.

    - parameter frame: view frame
    
    - returns: view
    */
    override init(frame: CGRect) {
        // 1. setup any properties here
        
        // 2. call super.init(frame:)
        super.init(frame: frame)
        
        // 3. Setup view from .xib file
        xibSetup()
        
        viewSetup()
    }
    
    /**
    NSCoder init
    
    - parameter aDecoder: coder
    
    - returns: view
    */
    required init?(coder aDecoder: NSCoder) {
        // 1. setup any properties here
        
        // 2. call super.init(coder:)
        super.init(coder: aDecoder)
        
        // 3. Setup view from .xib file
        xibSetup()
        
        viewSetup()
    }
    
    // MARK: - View setup methonds
    
    /**
    Setup view from xib.
    */
    private func xibSetup() {
        view = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        view.frame = bounds
        
        // Make the view stretch with containing view
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
    }
    
    /**
    Load view from nib.
    
    - returns: view from nib.
    */
    private func loadViewFromNib() -> UIView {
        
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "BusLineView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }
    /**
    Do some view setup.
    */
    private func viewSetup() {
        cornerRadius = frame.width / 2
    }
}
