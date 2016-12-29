//
//  AvatarView.swift
//  Spot
//
//  Created by Peter on 12/26/16.
//  Copyright © 2016 Peter. All rights reserved.
//

import UIKit
import Foundation

class Button: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initialize()
    }
    
    func initialize() {
        self.titleLabel?.font = UIFont(name: Constants.Fonts.heavy, size: 28)
        self.layer.cornerRadius = CGFloat(Constants.Dimens.cornerRadius)
    }
    
    func setupForPrimary () {
        self.backgroundColor = Constants.Colors.blue
        self.setTitleColor(.white, for: .normal)
    }
    
    func setupForSecondary () {
        self.backgroundColor = Constants.Colors.medGray
        self.setTitleColor(.white, for: .normal)
    }
    
}
