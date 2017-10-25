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

    override init(frame: CGRect) {
        // 1. setup any properties here

        // 2. call super.init(frame:)
        super.init(frame: frame)

        // 3. Setup view from .xib file
        xibSetup()

        viewSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        // 1. setup any properties here

        // 2. call super.init(coder:)
        super.init(coder: aDecoder)

        // 3. Setup view from .xib file
        xibSetup()

        viewSetup()
    }

    func populateWithBusLine(_ busLine: BusLine) {
        self.busLine.text = String(busLine.number)
        do {
            backgroundColor = try UIColor(busLine.hexColor)
        } catch {
            // Fail safe color
            backgroundColor = UIColor.clear
        }
    }

    // MARK: - View setup methonds

    fileprivate func xibSetup() {
        view = loadViewFromNib()

        // use bounds not frame or it'll be offset
        view.frame = bounds

        // Make the view stretch with containing view
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
    }

    fileprivate func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "BusLineView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        // swiftlint:disable:previous force_cast

        return view
    }

    fileprivate func viewSetup() {
        cornerRadius = frame.width / 2
    }
}
