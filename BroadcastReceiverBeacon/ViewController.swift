//
//  ViewController.swift
//  BroadcastReceiverBeacon
//
//  Created by Anand Upadhyay on 28/08/24.
//

import UIKit
import CoreBluetooth
import CoreLocation
import Foundation

enum BEACON_POWER: Int {
    case BEACON_POWER_HIGH  = -56
    case BEACON_POWER_MEDIUM =   -66
    case BEACON_POWER_LOW   = -75
    case BEACON_POWER_ULTRA_LOW = 0
}

let localBeaconUUID = "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5"
let localBeaconMajor: CLBeaconMajorValue = 123
let localBeaconMinor: CLBeaconMinorValue = 456
let localBeaconId = "Beacon007"

class ViewController: UIViewController, UITextFieldDelegate,CLLocationManagerDelegate {

    var localBeacon: CLBeaconRegion!
    var beaconPeripheralData: NSDictionary!
    var peripheralManager: CBPeripheralManager!
    var locationManager: CLLocationManager!
    var monitoring = false
    let firstConstraint = CLBeaconIdentityConstraint(uuid: UUID(uuidString: localBeaconUUID)!)
    @IBOutlet weak var txtBeaconIdToMonitor: UITextField!
    @IBOutlet weak var txtBeaconUDID: UITextField!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var btnCreateBeacon: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeLocationManager()
        
        // Do any additional setup after loading the view.
    }

    
    @IBAction func calculateDistance(_ sender: Any) {
        let uuid = UUID(uuidString: localBeaconUUID)!
        let beaconRegion  = CLBeaconRegion(uuid: uuid, identifier: localBeaconId)//, major: localBeaconMajor, minor: localBeaconMinor, identifier: localBeaconId)
        locationManager?.startMonitoring(for: beaconRegion)
        locationManager?.startRangingBeacons(satisfying: firstConstraint)
        monitoring = true
        locationManager.startUpdatingLocation()
        txtBeaconIdToMonitor.text = localBeaconUUID
        debugPrint("Monitoring Region:\(locationManager.monitoredRegions)")
    }
    
    @IBAction func createBeacon(_ sender: Any){
        self.initLocalBeacon()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        true
    }
    
    func initializeLocationManager(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        
    }
    
    //Location Manager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
//        debugPrint("Location did updated:\(manager.location.lo)")
    }
    
}

extension ViewController{
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus){
        if status == .authorizedAlways && !monitoring {
            debugPrint("got the permission")
            monitoring = true
        }else{
          debugPrint("No Permission")
            monitoring = false
        }
    }
    
    func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
        
    

    }
    
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        
    }

    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        
    }
    
    func locationManager(manager: CLLocationManager!, monitoringDidFailForRegion region: CLRegion!, withError error: NSError!){
        
    }
    
    func locationManager(_ manager: CLLocationManager,didRange beacons: [CLBeacon],satisfying beaconConstraint: CLBeaconIdentityConstraint){
        if beacons.count > 0 {
            let uuid = UUID(uuidString: localBeaconUUID)!
            let bcObj = beacons.filter{$0.uuid == uuid}.first
            if let beacon = bcObj {
                self.lblDistance.text = "\(beacon.accuracy)meteres | \(getProximity(prox: beacon.proximity))"
            }
        }
    }
    
    static func calculateAccuracy(txPower: Int, rssi: Double) -> Double {
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
                self.view.backgroundColor = UIColor.blue
                return "FAR"
            case .near:
                self.view.backgroundColor = UIColor.orange
                return "NEAR"
            case .immediate:
                self.view.backgroundColor = UIColor.red
                return "RIGHT HERE"
            default:
                self.view.backgroundColor = UIColor.gray
                return "UNKNOWN"
            }
    }
    
//    func updateDistance(distance: CLProximity, accuracy: CLLocation) {
//    UIView.animateWithDuration(0.8) { [unowned self] in
//
//    switch distance {
//    case .Unknown:
//
//    self.view.backgroundColor = UIColor.grayColor()
//
//    self.distanceReading.text = "UNKNOWN "
//
//
//
//    case .Far:
//
//    self.view.backgroundColor = UIColor.blueColor()
//
//    self.distanceReading.text = "FAR"
//
//
//
//    case .Near:
//
//    self.view.backgroundColor = UIColor.orangeColor()
//
//    self.distanceReading.text = "NEAR"
//
//
//
//    case .Immediate:
//
//    self.view.backgroundColor = UIColor.redColor()
//
//    self.distanceReading.text = "RIGHT HERE"
//
//    }
//
//    }
//
//    }
    
}
extension ViewController : CBPeripheralManagerDelegate {
    
        func initLocalBeacon() {
            if localBeacon != nil {
                stopLocalBeacon()
            }

            let uuid = UUID(uuidString: localBeaconUUID)!
            localBeacon  = CLBeaconRegion(uuid: uuid, major: localBeaconMajor, minor: localBeaconMinor, identifier: localBeaconId)

            beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: BEACON_POWER.BEACON_POWER_HIGH.rawValue as NSNumber)
            peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
        }

        func stopLocalBeacon() {
            peripheralManager.stopAdvertising()
            peripheralManager = nil
            beaconPeripheralData = nil
            localBeacon = nil
        }

        func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager){
            if peripheral.state == .poweredOn {
                peripheralManager.startAdvertising(beaconPeripheralData as? [String: Any])
                txtBeaconUDID.text = localBeaconUUID
            } else if peripheral.state == .poweredOff {
                peripheralManager.stopAdvertising()
            }
        }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: (any Error)?) {
        if error != nil{
            debugPrint("error:\(error.debugDescription)")
        }else{
            debugPrint("isAdevertising :\(peripheral.isAdvertising)")
        }
    }
}

