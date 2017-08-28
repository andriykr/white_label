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
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var cnstTitleHeight: NSLayoutConstraint!
    @IBOutlet weak var lblShortTExt: UILabel!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var viewArticleContainer: UIView!
    @IBOutlet var btnShare:UIButton!
    @IBOutlet var btnBookmark:UIButton!
    lazy var baseURL: URL = {
        return Bundle.main.url(forResource: "iFrame", withExtension: "html")!
    }()
    
    let heightOfDateView:CGFloat = 44
    var idetifier:String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
         gradientView.backgroundColor = GradientColor(.topToBottom, frame:gradientView.frame, colors: [UIColor.black.withAlphaComponent(0.0) ,UIColor.black.withAlphaComponent(0.8)])
        selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    
    func calculateHeight() {
    }
    
    func bookmarkNews() {
        if let news = WLCoreDataManager.shared.getNews(identifier: idetifier) {
            news.isBookmark = !news.isBookmark
            btnBookmark.isSelected = news.isBookmark
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
            btnBookmark.addTarget(self, action: #selector(bookmarkNews), for: .touchUpInside)
            idetifier = article.identifier!
            if let shortText = article.shortText {
                lblShortTExt.text = shortText
            } else {
                lblShortTExt.text = ""
            }
        } else if let link = dataObject as? WLLink {
            imgArticle.image = nil
            imgArticle.sd_setShowActivityIndicatorView(true)
            imgArticle.sd_setIndicatorStyle(.gray)
            self.idetifier = link.identifier!
            let dateFormatter = DateFormatter.init()
            dateFormatter.dateFormat = "dd MMM YYYY"
            self.lblDate.text = dateFormatter.string(from: link.date!)
            self.btnBookmark.isSelected = link.isBookmark
            self.btnBookmark.addTarget(self, action: #selector(self.bookmarkNews), for: .touchUpInside)
            if link.headerimage?.url == nil {
                if let urlImage = link.image {
                    imgArticle.sd_setImage(with: URL.init(string: urlImage), placeholderImage: nil, options: [.progressiveDownload])
                } else {
                    imgArticle.image = nil
                }
            } else {
                if let urlImage = link.headerimage?.url {
                    imgArticle.sd_setImage(with: URL.init(string: urlImage), placeholderImage: nil, options: [.progressiveDownload])
                } else {
                    imgArticle.image = nil
                }
            }
            lblTitle.text = link.headline
            self.lblShortTExt.text = link.shortText
                
        }
    }
}


