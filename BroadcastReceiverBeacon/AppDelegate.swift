//
//  AppDelegate.swift
//  BroadcastReceiverBeacon
//
//  Created by Anand Upadhyay on 28/08/24.
//

import UIKit
import CoreLocation
import CoreBluetooth

enum BEACON_POWER: Int {
    case BEACON_POWER_HIGH  = -56
    case BEACON_POWER_MEDIUM =   -66
    case BEACON_POWER_LOW   = -75
    case BEACON_POWER_ULTRA_LOW = 0
}

let localBeaconUUID = "5A4BABCD-174E-4BAC-A814-092E77F6B7E5"
let localBeaconMajor: CLBeaconMajorValue = 123
let localBeaconMinor: CLBeaconMinorValue = 456
let localBeaconIdentifier = "Beacon007"

let APPDELEGATE = (UIApplication.shared.delegate as! AppDelegate)
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var localBeacon: CLBeaconRegion!
    var beaconPeripheralData: NSDictionary!
    var peripheralManager: CBPeripheralManager!
    var locationManager: CLLocationManager!
    var monitoring = false
    var viewController: ViewController!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        APPDELEGATE.initializeLocationManager()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func initializeLocationManager(){
        locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
        locationManager.startUpdatingLocation()
        locationManager.activityType = .other
        locationManager.pausesLocationUpdatesAutomatically = false
        let  region = CLBeaconRegion(uuid: UUID(uuidString: localBeaconUUID)!
,major: CLBeaconMajorValue(localBeaconMajor), minor: CLBeaconMajorValue(localBeaconMinor),identifier: localBeaconIdentifier)
        APPDELEGATE.locationManager.stopMonitoring(for: region)
    }
    
    func startScanning()
    {
      let uuid = UUID(uuidString: localBeaconUUID)!
      let  region = CLBeaconRegion(uuid: uuid ,major: CLBeaconMajorValue(localBeaconMajor), minor: CLBeaconMajorValue(localBeaconMinor),identifier: localBeaconIdentifier)
        region.notifyOnEntry = true
        region.notifyOnExit = true
        region.notifyEntryStateOnDisplay = true
       locationManager.startMonitoring(for: region)
       locationManager.startRangingBeacons(in: region)
    }
    
    func calculateAccuracy(txPower: Int, rssi: Double) -> Double {
        if rssi == 0 {
            return -1.0 // if we cannot determine accuracy, return -1.
        }

        let ratio = rssi / Double(txPower)
        if ratio < 1.0 {
            return pow(ratio, 10)
        } else {
            let accuracy = 0.89976 * pow(ratio, 7.7095) + 0.111
            return accuracy
        }
    }
    
    func getProximity(prox : CLProximity) -> String{
        switch prox {
            case .far:
//                self.view.backgroundColor = UIColor.blue
                return "FAR"
            case .near:
//                self.view.backgroundColor = UIColor.orange
                return "NEAR"
            case .immediate:
//                self.view.backgroundColor = UIColor.red
                return "RIGHT HERE"
            default:
//                self.view.backgroundColor = UIColor.gray
                return "UNKNOWN"
            }
    }
}
extension AppDelegate : CLLocationManagerDelegate{
    
    //Location Manager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let newLat = Double(manager.location?.coordinate.latitude ?? 0.0)
        let newLon = Double(manager.location?.coordinate.longitude ?? 0.0)
        debugPrint("Location did lat:\(newLat) lon:\(newLon)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
     
        if manager.authorizationStatus == .authorizedAlways {
                if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                    if CLLocationManager.isRangingAvailable() {
                        
                    }
                }
            }
//        if status == .authorizedAlways{ // && !monitoring {
//            debugPrint("got the permission")
//            monitoring = true
//        }else{
//          debugPrint("No Permission")
//            monitoring = false
//        }
    }
       
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
       debugPrint("didRangeBeacons:\(String(describing: beacons))")
       if beacons.count > 0 {
           let uuid = UUID(uuidString: localBeaconUUID)!
           let bcObj = beacons.filter{$0.uuid == uuid}.first
           if let beacon = bcObj {
               self.viewController.txtBeaconIdToMonitor.text = beacon.uuid.uuidString
               self.viewController.lblDistance.text = "\(String(describing: beacon.accuracy)) meteres | \(getProximity(prox: beacon.proximity))"
               
//                showToast(message: "\(beacon.accuracy)meteres | \(getProximity(prox: beacon.proximity))")
           }
       }
   }
   
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
       debugPrint("didEnterRegion")
   }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
       debugPrint("didExitRegion")
   }
   
    private func locationManager(manager: CLLocationManager!, monitoringDidFailForRegion region: CLRegion!, withError error: NSError!){
       debugPrint("monitoringDidFailForRegion:\(error.localizedDescription)")
   }
   
   func locationManager(_ manager: CLLocationManager,didRange beacons: [CLBeacon],satisfying beaconConstraint: CLBeaconIdentityConstraint){
       debugPrint("beacons \(beacons)")
//        if beacons.count > 0 {
//            let uuid = UUID(uuidString: localBeaconUUID)!
//            let bcObj = beacons.filter{$0.uuid == uuid}.first
//            if let beacon = bcObj {
//                self.lblDistance.text = "\(beacon.accuracy)meteres | \(getProximity(prox: beacon.proximity))"
//                showToast(message: "\(beacon.accuracy)meteres | \(getProximity(prox: beacon.proximity))")
//            }
//        }
   }
}
extension AppDelegate : CBPeripheralManagerDelegate {
    
        func initLocalBeacon() {
            if localBeacon != nil {
                stopLocalBeacon()
            }

            let uuid = UUID(uuidString: localBeaconUUID)!
            localBeacon  = CLBeaconRegion(uuid: uuid, major: localBeaconMajor, minor: localBeaconMinor, identifier: localBeaconIdentifier)
            beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: BEACON_POWER.BEACON_POWER_HIGH.rawValue as NSNumber)
            peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
        }

        func stopLocalBeacon(){
            peripheralManager.stopAdvertising()
            peripheralManager = nil
            beaconPeripheralData = nil
            localBeacon = nil
        }

        func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager){
            if peripheral.state == .poweredOn {
                peripheralManager.startAdvertising(beaconPeripheralData as? [String: Any])
                self.viewController.txtBeaconUDID.text = localBeaconUUID
            } else if peripheral.state == .poweredOff {
                peripheralManager.stopAdvertising()
            }
        }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: (any Error)?) {
        if error != nil{
            debugPrint("error:\(error.debugDescription)")
        }else{
            debugPrint("Started Adevertising :\(peripheral.isAdvertising)")
            self.viewController.showToast(message: "Started Adevertising :\(peripheral.isAdvertising)")
        }
    }
}

/*
 Reference Links
 https://stackoverflow.com/questions/24677199/determining-distance-and-direction-of-idevice-from-beacon
 Simulating Beacon
 https://stackoverflow.com/questions/41037556/simulate-beacon-with-iphone-using-dedicated-class
 https://stackoverflow.com/questions/35680718/using-iphone-as-ibeacon-transmitter
 https://stackoverflow.com/questions/58286962/how-to-resolve-initproximityuuididentifier-was-deprecated-in-ios-13-0-for
 Apple Guidelines
 https://stackoverflow.com/questions/41036077/how-to-run-iphone-as-a-beacon-in-background-in-both-xcodeswift-and-phonegap/41040326#41040326
 Constant Ranging While in Region
 https://stackoverflow.com/questions/75395535/detection-of-all-ibeacons-nearby-with-the-same-uuid-on-ios
 
 Start Ranging Beacon
 https://stackoverflow.com/questions/78439506/2024-beacon-app-startmonitoringfor-region-or
 https://stackoverflow.com/questions/75395535/detection-of-all-ibeacons-nearby-with-the-same-uuid-on-ios
 https://stackoverflow.com/questions/60729509/swift-corelocation-ranging-beacons-using-clbeaconidentityconstraint-does-not
 Beacon Ranging
 https://developer.apple.com/documentation/corelocation/ranging-for-beacons
 
 Beacon Distance
 https://stackoverflow.com/questions/20416218/understanding-ibeacon-distancing/20434019#20434019
 https://www.hackingwithswift.com/example-code/location/how-to-detect-ibeacons
 Distance in Proximity https://www.hackingwithswift.com/read/22/3/hunting-the-beacon-clbeaconregion
 
 
 Reconnecting with BLE Device if App is terminated
 https://blog.grio.com/2023/03/ibeacon-reconnecting-an-ios-app-to-a-bluetooth-device-if-the-app-is-terminated.html
 
 
 Beacon Notification Looping instead of Showing Once
 https://www.hackingwithswift.com/forums/swift/ibeacon-app-problem-with-notifications-looping-instead-of-showing-just-once/2158
 
 
 */
