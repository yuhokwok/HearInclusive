//
//  MenuButton.swift
//  HearInclusive
//
//  Created by SAME Team on 30/8/2022.
//

import Foundation
import UIKit
import Vision

class MenuButton : UIButton {
    @IBOutlet var associatedView : MenuButton?
    override var isHighlighted: Bool {
        didSet {
            if let associatedViewHighlighted = self.associatedView?.isHighlighted {
                if associatedViewHighlighted != isHighlighted {
                    self.associatedView?.isHighlighted = isHighlighted
                }
            }
        }
    }
}

struct RecognizedWord {
    let string : String?
    let boundingBox : VNRectangleObservation
}
