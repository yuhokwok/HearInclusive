//
//  ExtractedWordCell.swift
//  HearInclusive
//
//  Created by Yu Ho Kwok on 6/7/2022.
//

import UIKit

class ExtractedWordCell : UICollectionViewCell {
    
    @IBOutlet var roundedRectView : RoundBorderView?
    @IBOutlet var label : UILabel?
    @IBOutlet var langCodeLabel : UILabel?
    @IBOutlet var numberLabel : UILabel?
    
    override var isSelected: Bool {
        didSet {
            if isSelected == true {
                roundedRectView?.borderColor = #colorLiteral(red: 0.07872826606, green: 0.4589015841, blue: 0.7732160687, alpha: 1)
                label?.textColor = #colorLiteral(red: 0.07872826606, green: 0.4589015841, blue: 0.7732160687, alpha: 1)
            } else {
                roundedRectView?.borderColor = #colorLiteral(red: 0.9627568126, green: 0.9594748616, blue: 0.9594045281, alpha: 1)
                label?.textColor = #colorLiteral(red: 0.3396087289, green: 0.3712625206, blue: 0.445853889, alpha: 1)
            }
        }
    }
}
