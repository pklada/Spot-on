//
//  LayoutHelpers.swift
//  Spot
//
//  Created by Peter on 12/28/16.
//  Copyright © 2016 Peter. All rights reserved.
//

import Foundation
import UIKit

func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
    let label = UILabel()
    label.frame = CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude)
    label.numberOfLines = 0
    label.lineBreakMode = NSLineBreakMode.byWordWrapping
    label.font = font
    label.text = text
    
    label.sizeToFit()
    return label.frame.height
}
