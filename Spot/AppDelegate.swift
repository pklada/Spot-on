//
//  AppDelegate.swift
//  Spot
//
//  Created by Peter on 12/26/16.
//  Copyright © 2016 Peter. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import GoogleSignIn
import CoreLocation
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?
    var locationManager: CLLocationManager!
    var notificationCenter: UNUserNotificationCenter!
    var tabBarController: UITabBarController!
    
    var modelController: SpotModelController!
    
    enum SpotActionTypes {
        case Exit
        case Enter
    }
    
    func configureAppBgdColor() {
        var color = AppState.sharedInstance.getColorForState()
        var bgdColor = UIColor.white
        
        if let color = color {
            bgdColor = UIColor.blend(color1: color, intensity1: 0.1, color2: UIColor.white, intensity2: 1)
        } else {
            color = Constants.Colors.darkGray
        }
        
        UIView.animate(withDuration: 0.2, delay: 0, options:.curveEaseInOut, animations: {
            UIApplication.shared.keyWindow?.rootViewController?.view.backgroundColor = bgdColor
            self.window?.rootViewController?.childViewControllers.last?.tabBarController?.tabBar.tintColor = color
        }, completion:nil)
    }


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        self.locationManager = CLLocationManager()
        self.notificationCenter = UNUserNotificationCenter.current()
        
        self.modelController = SpotModelController()
        if let tbc = self.window?.rootViewController as? SpotTabBarController {
            tbc.modelController = self.modelController
        }
        
        setupNoficationCenter()
        
        // Override point for customization after application launch.
        FIRApp.configure()
        
        GIDSignIn.sharedInstance().delegate = self
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.notificationCenter.delegate = self
        
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        
        if let user = AccountHelpers.getCurrentUser() {
            AccountHelpers.signIn(user, spotModel: self.modelController)
        }
        
        UITabBar.appearance().tintColor = UIColor.darkGray
        
        enableLocationServices()
        
        let options: UNAuthorizationOptions = [.alert, .sound]
        self.notificationCenter?.requestAuthorization(options: options) { (granted, error) in
            if !granted {
                print("Permission not granted")
            }
        }
        
        return true
    }
    
    func setupGeofence() {
        let geofenceRegionCenter = CLLocationCoordinate2DMake(AppState.sharedInstance.locationPointLat, AppState.sharedInstance.locationPointLong)
        let geofenceRegion = CLCircularRegion(center: geofenceRegionCenter,
                                              radius: AppState.sharedInstance.locationFenceRadius,
                                              identifier: "UniqueIdentifier")
        
        geofenceRegion.notifyOnEntry = true
        geofenceRegion.notifyOnExit = true
        
        self.locationManager.startMonitoring(for: geofenceRegion)
        self.locationManager.requestState(for: geofenceRegion)
    }
    
    func enableLocationServices() {
        self.locationManager.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            // Request when-in-use authorization initially
            self.locationManager.requestAlwaysAuthorization()
            break
            
        case .restricted, .denied:
            // Disable location features
            break
            
        case .authorizedWhenInUse:
            // Enable basic location features
            setupGeofence()
            break
            
        case .authorizedAlways:
            // Enable any of your app's location features
            setupGeofence()
            break
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
        -> Bool {
            return GIDSignIn.sharedInstance().handle(url,
                                                        sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                        annotation: [:])
    }
    
    func doSignIn(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, completion: ((String) -> Void)?) {
        self.sign(signIn, didSignInFor: user, withError: nil)
        
    }
    
    // google sign in
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
    
    }
    
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
                withError error: NSError!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
}

extension AppDelegate: CLLocationManagerDelegate {
    
    // called when user Exits a monitored region
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            // Do what you want if this information
            self.handleNotificationAction(type: .Exit)
        }
    }
    
    // called when user Enters a monitored region
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            // Do what you want if this information
            self.handleNotificationAction(type: .Enter)
        }
    }
    
    func setupNoficationCenter() {
        let center = UNUserNotificationCenter.current()
        // create action buttons
        let actionLeaveSpot = UNNotificationAction(identifier: "LEAVE_SPOT", title: "Leave Spot", options: [.destructive])
        let actionTakeSpot = UNNotificationAction(identifier: "TAKE_SPOT", title: "Take Spot", options: [])
        
        // define category
        let exitCategory = UNNotificationCategory(identifier: "EXIT_CATEGORY", actions: [actionLeaveSpot], intentIdentifiers: [], options: [])
        
        // define category
        let enterCategory = UNNotificationCategory(identifier: "ENTER_CATEGORY", actions: [actionTakeSpot], intentIdentifiers: [], options: [])
        
        // register category
        center.setNotificationCategories([exitCategory, enterCategory])
    }
    
    func handleNotificationAction(type: SpotActionTypes) {
        
        if (AppState.sharedInstance.spotState == .Owned && type == .Enter) {
            // if you already own the spot, and you enter again, don't do anything
            return
        }
        
        if (AppState.sharedInstance.spotState == .Open && type == .Exit) {
            // if the spot is open and you leave, don't do anything
            return
        }
        
        if (AppState.sharedInstance.spotState == .Occupied || AppState.sharedInstance.spotState == .NoAuth) {
            // if someone else is in the spot, you can't do anything so don't do anything
            // also return if for some reason the user isn't authed
            return
        }
        
        let center = UNUserNotificationCenter.current()
        let identifier = "123"
        let content = UNMutableNotificationContent()
        content.sound = UNNotificationSound.default()
        
        switch type {
        case .Enter:
            content.title = "Welcome!"
            content.body = "You've entered the region. Did you take the spot?"
            content.categoryIdentifier = "ENTER_CATEGORY"
        case .Exit:
            content.title = "Bye!"
            content.body = "You left the region. Did you give up the spot?"
            content.categoryIdentifier = "EXIT_CATEGORY"
        }
        
        
        // the actual trigger object
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5,
                                                        repeats: false)
        
        // the notification request object
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content,
                                            trigger: trigger)
        
        
        // trying to add the notification request to notification center
        center.add(request, withCompletionHandler: { (error) in
            if error != nil {
                print("Error adding notification with identifier: \(identifier)")
            }
        })
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // when app is onpen and in foregroud
        completionHandler(.alert)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let spotHelpers = SpotHelpers()
        
        switch response.actionIdentifier {
        case "LEAVE_SPOT":
            spotHelpers.relinquishSpot()
        case "TAKE_SPOT":
            spotHelpers.claimSpot(spotModel: self.modelController)
        default:
            return
        }
        
        completionHandler()
    }
    
}

