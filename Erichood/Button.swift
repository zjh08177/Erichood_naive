//
//  Button.swift
//  Erichood
//
//  Created by Jiahao Zhang on 11/19/16.
//  Copyright © 2016 Jiahao Zhang. All rights reserved.
//

import Foundation
import UIKit

class Button: UIButton {
    init(frame: CGRect, buttonTitle: String, target: UIViewController, action: Selector) {
        super.init(frame: frame)
        self.setTitle(buttonTitle, forState: .Normal)
        self.setTitleColor(UIColor.blueColor(), forState: .Normal)
        self.addTarget(target, action: action, forControlEvents: .TouchUpInside)
        self.backgroundColor = UIColor.lightGrayColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
