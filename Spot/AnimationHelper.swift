//
//  AnimationHelper.swift
//  Spot
//
//  Created by Peter on 12/29/16.
//  Copyright © 2016 Peter. All rights reserved.
//

import Foundation
import pop

class AnimationHelper: NSObject {
    
    static func createSpringAnimation(property: String, toValue: Any?, fromValue: Any?, target: AnyObject, springBounce: CGFloat? = 12, springSpeed: CGFloat? = 18, keyName: String? = "animation") {
        let anim = POPSpringAnimation.init(propertyNamed: property)
        
        if let toValue = toValue {
            anim?.toValue = toValue
        }
        
        if let fromValue = fromValue {
            anim?.fromValue = fromValue
        }
        
        anim?.springBounciness = 12
        anim?.springSpeed = 18
        
        
        target.pop_add(anim, forKey: keyName)
    }
}
