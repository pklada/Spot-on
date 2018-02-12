//
//  SpotTabBarController.swift
//  Spot
//
//  Created by Peter on 2/12/18.
//  Copyright © 2018 Peter. All rights reserved.
//

import Foundation
import UIKit

class SpotTabBarController: UITabBarController {
    
    var modelController: SpotModelController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let spotViewController = self.viewControllers![0] as! FirstViewController
        spotViewController.modelController = modelController
        
        let accountViewController = self.viewControllers![2] as! AccountViewController
        accountViewController.modelController = modelController
    }
    
}
