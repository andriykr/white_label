//
//  WLFullScreenImageCell.swift
//  WhiteLabelApp
//
//  Created by Taras Serbin on 5/5/17.
//  Copyright © 2017 Taras Serbin. All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework
class WLFullScreenImageCell: UITableViewCell {

    @IBOutlet weak var articleContainer: UIView!
    @IBOutlet weak var imgArticle: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnBookmark: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var cnstTitleHeight: NSLayoutConstraint!
    @IBOutlet weak var lblShortTExt: UILabel!
    @IBOutlet weak var gradientView: UIView!
    
    let heightOfDateView:CGFloat = 44
    var idetifier:String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
         gradientView.backgroundColor = GradientColor(.topToBottom, frame:gradientView.frame, colors: [UIColor.black.withAlphaComponent(0.0) ,UIColor.black.withAlphaComponent(0.8)])
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    
    func calculateHeight() {
    }
    
    func bookmarkArticle() {
        if let article = WLCoreDataManager.shared.getArticle(identifier: idetifier) {
            article.isBookmark = !article.isBookmark
            btnBookmark.isSelected = article.isBookmark
            WLCoreDataManager.shared.saveContext()
        }
    }
}

extension WLFullScreenImageCell : CellConfigurable {
    var dataObjectIdentifier:String {
        return self.idetifier
    }
    
    var imageArticle:UIImage?  {
        return self.imgArticle.image
    }
    func configure(dataObject: NSManagedObject) {
        if let article = dataObject as? WLArticle {
            lblTitle.text = article.headline
            imgArticle.sd_setShowActivityIndicatorView(true)
            imgArticle.sd_setIndicatorStyle(.gray)
            imgArticle.image = nil
            
            if let urlImage = article.headerimage?.url {
                imgArticle.sd_setImage(with: URL.init(string: urlImage), placeholderImage: nil, options: [.progressiveDownload])
            } else {
                imgArticle.image = nil
            }
            let brand = article.brand!.firstObject as! WLBrand
            imgArticle.backgroundColor = UIColor.init(hexString:brand.theme!.cellBackgroundColor!)
            imgArticle.clipsToBounds = true
            let dateFormatter = DateFormatter.init()
            dateFormatter.dateFormat = "dd MMM YYYY"
            lblDate.text = dateFormatter.string(from: article.date!)
            btnBookmark.isSelected = article.isBookmark
            btnBookmark.addTarget(self, action: #selector(bookmarkArticle), for: .touchUpInside)
            idetifier = article.identifier!
            if let shortText = article.shortText {
                lblShortTExt.text = shortText
            } else {
                lblShortTExt.text = ""
            }
        }
    }


}
