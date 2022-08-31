//
//  RoundBorderView.swift
//  HearInclusive
//
//  Created by SAME Team on 5/7/2022.
//

import UIKit

@IBDesignable
class RoundBorderView : UIView {
    @IBInspectable
    var cornerRadius : CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable
    var borderWidth : CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable
    var borderColor : UIColor = .clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
}
