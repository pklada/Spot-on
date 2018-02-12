//
//  AppState.swift
//  Spot
//
//  Created by Peter on 12/26/16.
//  Copyright © 2016 Peter. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class AppState: NSObject {
    
    static let sharedInstance = AppState()
    
    var spotState: SpotState = .Default
    
    func setState(state: SpotState) {
        spotState = state
    }
    
    func getColorForState() -> UIColor? {
        var color = UIColor()
        
        switch self.spotState {
        case .Open:
            color = Constants.Colors.green
        case .Occupied:
            color = Constants.Colors.red
        case .Owned:
            color = Constants.Colors.blue
        case .NoAuth:
            return nil
        default:
            return nil
        }
        
        return color
    }
    
    var locationPointLat: CLLocationDegrees = 37.784282
    var locationPointLong: CLLocationDegrees = -122.392852
    var locationFenceRadius: Double = 100
}
