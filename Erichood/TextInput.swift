//
//  TextInput.swift
//  Erichood
//
//  Created by Jiahao Zhang on 11/19/16.
//  Copyright © 2016 Jiahao Zhang. All rights reserved.
//

import Foundation
import UIKit

class TextInput: UIView {

    var textInputField: UITextField!
    
    init(frame: CGRect, textInputName: String) {
        super.init(frame: frame)
        
        textInputField = UITextField(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        textInputField.borderStyle = UITextBorderStyle.RoundedRect
        textInputField.backgroundColor = UIColor.lightGrayColor()
        textInputField.placeholder = "Type a Symbol"
        
        addSubview(textInputField)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
