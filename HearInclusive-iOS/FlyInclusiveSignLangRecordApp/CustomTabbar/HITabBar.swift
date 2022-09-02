//
//  HITabBar.swift
//  HearInclusive
//
//  Created by SAME Team on 22/8/2022.
//

import UIKit

protocol HITabBarDelegate {
    func hiTabBar(_ tabBar : HITabBar, didSelecteIndex : Int, from oldIndex : Int)
}

class HITabBar : UIView {
    var selectedIndex = 0 {
        didSet {
            for tabImageView in tabImageViews {
                if tabImageView.tag == selectedIndex {
                    tabImageView.alpha = 1
                } else {
                    tabImageView.alpha = 0
                }
            }
            
            for tabIconView in tabIconViews {
                if tabIconView.tag == selectedIndex {
                    tabIconView.tintColor = #colorLiteral(red: 0.07536371797, green: 0.1716218889, blue: 0.3743003011, alpha: 1)
                } else {
                    tabIconView.tintColor = .gray
                }
            }
            
            for tabTitle in tabTitles {
                if tabTitle.tag == selectedIndex {
                    tabTitle.textColor = #colorLiteral(red: 0.07536371797, green: 0.1716218889, blue: 0.3743003011, alpha: 1)
                } else {
                    tabTitle.textColor = .gray
                }
            }
        }
    }
    
    var delegate : HITabBarDelegate?
    
    @IBOutlet var tabImageViews : [UIImageView]!
    @IBOutlet var tabIconViews : [UIImageView]!
    @IBOutlet var tabTitles : [UILabel]!
    
    @IBAction func btnClicked(_ btn : UIButton){
        let tag = btn.tag
        
        guard selectedIndex != tag else {
            return
        }
        
        let oldIndex = selectedIndex
        selectedIndex = tag
        self.delegate?.hiTabBar(self, didSelecteIndex: selectedIndex, from: oldIndex)
    }
    
}
