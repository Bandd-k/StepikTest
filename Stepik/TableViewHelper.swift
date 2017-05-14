//
//  TableViewHelper.swift
//  Stepik
//
//  Created by Denis Karpenko on 14.05.17.
//  Copyright © 2017 Denis Karpenko. All rights reserved.
//

import Foundation
import UIKit

class TableViewHelper {
    
    class func EmptyMessage(message:String, viewController:UITableView) {
        
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: viewController.contentSize.width, height: viewController.contentSize.height))
        messageLabel.text = message
        messageLabel.textColor = UIColor.black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()
        
        viewController.backgroundView = messageLabel;
        viewController.separatorStyle = .none;
    }
}
