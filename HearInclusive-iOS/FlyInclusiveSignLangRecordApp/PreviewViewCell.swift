//
//  PreviewViewCell.swift
//  HearInclusive
//
//  Created by Yu Ho Kwok on 15/6/2022.
//

import UIKit

class PreviewViewCell: UITableViewCell {

    @IBOutlet var label : UILabel!
    @IBOutlet var tbView : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
