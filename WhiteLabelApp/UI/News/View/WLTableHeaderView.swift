//
//  WLTableHeaderView.swift
//  WhiteLabelApp
//
//  Created by Taras Serbin on 5/3/17.
//  Copyright © 2017 Taras Serbin. All rights reserved.
//

import UIKit

class WLTableHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var lblSectionName: UILabel!
    @IBOutlet weak var imgLogo: UIImageView!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
