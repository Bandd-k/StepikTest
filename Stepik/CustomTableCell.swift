//
//  CustomTableCell.swift
//  Stepik
//
//  Created by Denis Karpenko on 14.05.17.
//  Copyright © 2017 Denis Karpenko. All rights reserved.
//

import UIKit

class CustomTableCell: UITableViewCell {


    @IBOutlet weak var courseName: UILabel!
    @IBOutlet weak var courseImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(data: Course?) {
        self.courseName.text = data?.title ?? ""
        let startUrl = "https://stepik.org"
        if let data = data{
            if let url = URL(string: startUrl+data.cover) {
                self.courseImage.kf.setImage(with: url,
                                      placeholder: UIImage(named: "placeholder"),
                                      options: nil,
                                      progressBlock: nil,
                                      completionHandler: nil)
            }
        }
    }

}
