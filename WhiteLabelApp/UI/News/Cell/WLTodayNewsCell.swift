//
//  WLTodayNewsCell.swift
//  WhiteLabelApp
//
//  Created by Taras Serbin on 5/3/17.
//  Copyright © 2017 Taras Serbin. All rights reserved.
//

import UIKit
import CoreData

class WLTodayNewsCell: UITableViewCell {
    
    
    @IBOutlet weak var articleContainer: UIView!
    @IBOutlet weak var imgArticle: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnBookmark: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var cnstTitleHeight: NSLayoutConstraint!

    
    let heightOfDateView:CGFloat = 44
    var idetifier:String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func calculateHeight() {
        print(articleContainer.frame.height, frame.height, imgArticle.frame.height)
        
        let size = lblTitle.sizeThatFits(CGSize.init(width: lblTitle.frame.width, height: CGFloat(FLT_MAX)))
        if size.height > frame.height * 0.333 - 44 {
            cnstTitleHeight.constant = frame.height * 0.333 - 44
        } else {
            cnstTitleHeight.constant = size.height
        }
        setNeedsDisplay()
        setNeedsLayout()
        layoutSubviews()
    }
    
    func bookmarkArticle() {
        if let article = WLCoreDataManager.shared.getArticle(identifier: idetifier) {
            article.isBookmark = !article.isBookmark
            btnBookmark.isSelected = article.isBookmark
            WLCoreDataManager.shared.saveContext()
        }
    }
}

extension WLTodayNewsCell : CellConfigurable {
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
            imgArticle.clipsToBounds = true
            let dateFormatter = DateFormatter.init()
            dateFormatter.dateFormat = "dd MMM YYYY"
            lblDate.text = dateFormatter.string(from: article.date!)
            if let backgroundColor = article.articleLayout?.backgroundColor {
                articleContainer.backgroundColor = UIColor.init(hexString: backgroundColor)
            }
            if let textColor = article.articleLayout?.textColor {
                lblDate.textColor = UIColor.init(hexString: textColor)
                lblTitle.textColor = UIColor.init(hexString: textColor)
                let imageNormal = btnBookmark.image(for: .normal)
                let imageSelected = btnBookmark.image(for: .selected)
                btnBookmark.setImage(imageNormal?.imageWithColor(newColor: UIColor.init(hexString: textColor)), for: .normal)
                btnBookmark.setImage(imageSelected?.imageWithColor(newColor: UIColor.init(hexString: textColor)), for: .selected)
            }
            let brand = article.brand!.firstObject as! WLBrand
            imgArticle.backgroundColor = UIColor.init(hexString:brand.theme!.cellBackgroundColor!)
            btnBookmark.isSelected = article.isBookmark
            btnBookmark.addTarget(self, action: #selector(bookmarkArticle), for: .touchUpInside)
            idetifier = article.identifier!
            calculateHeight()
            
        }
    }
}

    
