//
//  MapViewController.swift
//  GoogleToolboxForMac
//
//  Created by Peter on 2/5/18.
//

import Foundation
import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    var circleOverlay: MKCircle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        let coordinates = CLLocationCoordinate2DMake(AppState.sharedInstance.locationPointLat, AppState.sharedInstance.locationPointLong)
        
        mapView.setCenter(coordinates, animated: true)
    
        mapView.setRegion(MKCoordinateRegionMakeWithDistance(coordinates, (AppState.sharedInstance.locationFenceRadius * 2), (AppState.sharedInstance.locationFenceRadius * 2)), animated: true)
        
        circleOverlay = MKCircle.init(center: coordinates, radius: AppState.sharedInstance.locationFenceRadius)
        mapView.add(circleOverlay)
        mapView.showsUserLocation = true
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        mapView.addAnnotation(annotation)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mapView.remove(circleOverlay)
        mapView.add(circleOverlay)
        
        let app = UIApplication.shared.delegate as! AppDelegate
        app.handleNotificationAction(type: .Enter)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circle = MKCircleRenderer.init(overlay: overlay)
        circle.strokeColor = AppState.sharedInstance.getColorForState()
        circle.lineWidth = 2
        circle.fillColor = AppState.sharedInstance.getColorForState()?.withAlphaComponent(0.1)
        return circle
    }
}
