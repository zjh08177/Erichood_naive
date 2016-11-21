//
//  TextLabel.swift
//  Erichood
//
//  Created by Jiahao Zhang on 11/19/16.
//  Copyright © 2016 Jiahao Zhang. All rights reserved.
//

import Foundation
import UIKit

class TextLabel: UILabel {
    var opinionSource: String!
    init(frame: CGRect, source: String, opinion: String) {
        super.init(frame: frame)
        opinionSource = source
        text = opinionSource + ":" + opinion
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addOpinion(opinion: String) {
        text = opinionSource + ":" + opinion
    }
}
