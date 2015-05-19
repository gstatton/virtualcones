//
//  AppDelegate.swift
//  AppDelegate
//
//  Created by gstatton on 5/19/15.
//
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    var window: UIWindow?
    var locationManager: CLLocationManager?
    var lastProximity: CLProximity?
    var lastDistance: CLLocationAccuracy?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        
        locationManager = CLLocationManager()
        
        if(locationManager!.respondsToSelector("requestAlwaysAuthorization")) {
            locationManager!.requestAlwaysAuthorization()
        }
        
        locationManager!.delegate = self
        locationManager!.pausesLocationUpdatesAutomatically = false

        
        //let uuidString = ["A4951234-C5B1-4B44-B512-1370F02D74DE","A4952345-C5B1-4B44-B512-1370F02D74DE"]
        let uuidString = "A4951234-C5B1-4B44-B512-1370F02D74DE"
        let beaconIdentifier = "3Wandel"
        
       // for id in uuidString{
            NSLog("monitoring for UUID: \(uuidString)")
            let beaconUUID:NSUUID = NSUUID(UUIDString: uuidString)!
            let beaconRegion:CLBeaconRegion = CLBeaconRegion(proximityUUID: beaconUUID,
                identifier: beaconIdentifier)
        

        
            
            NSLog("beaconRegion: \(beaconRegion)")
            locationManager!.startMonitoringForRegion(beaconRegion)
            locationManager!.startRangingBeaconsInRegion(beaconRegion)
            locationManager!.startUpdatingLocation()
            
       // }
        
        if(application.respondsToSelector("registerUserNotificationSettings:")) {
            application.registerUserNotificationSettings(
                UIUserNotificationSettings(
                    forTypes: UIUserNotificationType.Alert | UIUserNotificationType.Sound,
                    categories: nil
                )
            )
        }
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

extension AppDelegate: CLLocationManagerDelegate {
    
    func put(params : Dictionary<String, Bool>, url : String, postCompleted : (succeeded: Bool, msg: String) -> ()) {
        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "PUT"
        
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Body: \(strData)")
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
            
            var msg = "No message"
            
            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
            if(err != nil) {
                println(err!.localizedDescription)
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error could not parse JSON: '\(jsonStr)'")
                postCompleted(succeeded: false, msg: "Error")
            }
            else {
                // The JSONObjectWithData constructor didn't return an error. But, we should still
                // check and make sure that json has a value using optional binding.
                if let parseJSON = json {
                    // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                    if let success = parseJSON["success"] as? Bool {
                        println("Succes: \(success)")
                        postCompleted(succeeded: success, msg: "Logged in.")
                    }
                    return
                }
                else {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON: \(jsonStr)")
                    postCompleted(succeeded: false, msg: "Error")
                }
            }
        })
        
        task.resume()
    }
    func get(params : Dictionary<String, Bool>, url : String, postCompleted : (succeeded: Bool, msg: String) -> ()) {
        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Body: \(strData)")
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
            
            var msg = "No message"
            
            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
            if(err != nil) {
                println(err!.localizedDescription)
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error could not parse JSON: '\(jsonStr)'")
                postCompleted(succeeded: false, msg: "Error")
            }
            else {
                // The JSONObjectWithData constructor didn't return an error. But, we should still
                // check and make sure that json has a value using optional binding.
                if let parseJSON = json {
                    // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                    if let success = parseJSON["success"] as? Bool {
                        println("Succes: \(success)")
                        postCompleted(succeeded: success, msg: "Logged in.")
                    }
                    return
                }
                else {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON: \(jsonStr)")
                    postCompleted(succeeded: false, msg: "Error")
                }
            }
        })
        
        task.resume()
    }
    
    
    func sendLocalNotificationWithMessage(message: String!, turnLights: Bool, groups: Int!) {
        let notification:UILocalNotification = UILocalNotification()
        notification.alertBody = message
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
        if(turnLights) {
            //Turn on Lights
            self.put(["on":true], url: "http://10.0.0.3/api/newdeveloper/groups/4/action") { (succeeded: Bool, msg: String) -> () in
            }
            
        } else {
            //Turn off Lights
            self.put(["on":false], url: "http://10.0.0.3/api/newdeveloper/groups/4/action") { (succeeded: Bool, msg: String) -> () in
                
            }
            
        }
    }
    
    
    
    func locationManager(manager: CLLocationManager!,
        didRangeBeacons beacons: [AnyObject]!,
        inRegion region: CLBeaconRegion!) {
            
            let viewController:ViewController = window!.rootViewController as! ViewController
            viewController.beacons = beacons as! [CLBeacon]?
            viewController.tableView!.reloadData()
            
            NSLog("didRangeBeacons: \(beacons)");
            NSLog("Region: \(region)")
            
            var message:String = ""
            var turnLights = false
            
            NSLog("Beacon Count: \(beacons.count)")
            
            if(beacons.count > 0) {
                let nearestBeacon:CLBeacon = beacons[0] as! CLBeacon
                
                if(nearestBeacon.proximity == lastProximity ||
                    nearestBeacon.proximity == CLProximity.Unknown) {
                        return;
                }
                lastProximity = nearestBeacon.proximity;
                switch nearestBeacon.accuracy {
                case -1...0:
                    return
                case 0.1...15:
                    message = "You are in the Room!: \(nearestBeacon.accuracy)"
                    turnLights = true
                case 15...100:
                    message = "You are Outisde the Room!: \(nearestBeacon.accuracy)"
                    turnLights = true
                default:
                    message = "You're LOST!!!"
                    turnLights = false
                }
            }else {
                
                if(lastProximity == CLProximity.Unknown) {
                    return;
                }
                
                message = "No beacons are nearby"
                
                turnLights = false
                lastProximity = CLProximity.Unknown
            }
            
            NSLog("%@", message)
            sendLocalNotificationWithMessage(message, turnLights: turnLights, groups: 4)
    }
    
    
    func locationManager(manager: CLLocationManager!,
        didEnterRegion region: CLRegion!) {
            manager.startRangingBeaconsInRegion(region as! CLBeaconRegion)
            manager.startUpdatingLocation()
            
            NSLog("You entered the region")
            
            sendLocalNotificationWithMessage("You entered the region", turnLights: true, groups: 4)
            
    }
    
    func locationManager(manager: CLLocationManager!,
        didExitRegion region: CLRegion!) {
            manager.stopRangingBeaconsInRegion(region as! CLBeaconRegion)
            manager.stopUpdatingLocation()
            
            NSLog("You exited the region")
            
            sendLocalNotificationWithMessage("You exited the region", turnLights: false, groups: 4)
            
    }
    
}

