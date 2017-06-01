//
//  WLYesterdayNewsCell.swift
//  WhiteLabelApp
//
//  Created by Taras Serbin on 4/18/17.
//  Copyright © 2017 Taras Serbin. All rights reserved.
//

import UIKit
import CoreData
import Contentful
import SDWebImage
import ChameleonFramework

class WLYesterdayNewsCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgArticle: UIImageView!
    @IBOutlet weak var btnBookmark: UIButton!
    @IBOutlet weak var gradientView: UIView!
    
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var lblDate: UILabel!
    var idetifier:String = ""
    override func awakeFromNib() {
        super.awakeFromNib()
        gradientView.backgroundColor = GradientColor(.topToBottom, frame:gradientView.frame, colors: [UIColor.black.withAlphaComponent(0.0) ,UIColor.black.withAlphaComponent(0.30)])
        let view  = UIView()
        view.backgroundColor = GradientColor(.topToBottom, frame:gradientView.frame, colors: [UIColor.black.withAlphaComponent(0.0) ,UIColor.black.withAlphaComponent(0.30)])
        selectedBackgroundView = view
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bookmarkArticle() {
        if let article = WLCoreDataManager.shared.getArticle(identifier: idetifier) {
            article.isBookmark = !article.isBookmark
            btnBookmark.isSelected = article.isBookmark
            WLCoreDataManager.shared.saveContext()
        }
    }
    
}

extension WLYesterdayNewsCell : CellConfigurable {
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
      
        }
    }
    
    
}
