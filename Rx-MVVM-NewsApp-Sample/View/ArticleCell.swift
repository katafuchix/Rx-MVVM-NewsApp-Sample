//
//  ArticleCell.swift
//  Rx-MVVM-NewsApp-Sample
//
//  Created by cano on 2022/06/18.
//

import UIKit

class ArticleCell: UITableViewCell {

    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var subTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(_ article: Article) {
        self.titleLabel.text     = article.title
        self.subTitleLabel.text  = article.description
    }
    
    func clear() {
        self.titleLabel.text     = ""
        self.subTitleLabel.text  = ""
    }
}
