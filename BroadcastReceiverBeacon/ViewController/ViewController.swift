//
//  ViewController.swift
//  BroadcastReceiverBeacon
//
//  Created by Anand Upadhyay on 28/08/24.
//

import UIKit
import Foundation
import UserNotifications

class ViewController: UIViewController, UITextFieldDelegate,UNUserNotificationCenterDelegate,UITableViewDelegate, UITableViewDataSource {
    var scanner: RNLBeaconScanner?
    //var arrayBeacons
    @IBOutlet weak var txtBeaconIdToMonitor: UITextField!
    @IBOutlet weak var txtBeaconUDID: UITextField!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var btnCreateBeacon: UIButton!
    @IBOutlet weak var btnCalculateDistance: UIButton!
    @IBOutlet weak var tblBeacons: UITableView!
    @IBOutlet weak var btnCancelAll: UIButton!
    
    
    @IBOutlet weak var txtMajor: UITextField!
    @IBOutlet weak var txtMinor: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        APPDELEGATE.viewController = self
        btnCancelAll.isEnabled = false

        
        //create the notificationCenter
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        // set the type as sound or badge
        center.requestAuthorization(options: [.sound,.alert,.badge]) { (granted, error) in
            if granted {
                print("Notification Enable Successfully")
            }else{
                print("Some Error Occure")
            }
        }
        UIApplication.shared.registerForRemoteNotifications()
        
        scanner = RNLBeaconScanner.shared()

        // Do any additional setup after loading the view.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken
        deviceToken: Data)
    {
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error:Error) {
        
    }
   
    @IBAction func calculateDistance(_ sender: Any){
        
        btnCreateBeacon.isEnabled = false
        btnCalculateDistance.isEnabled = false
        btnCancelAll.isEnabled = true
        btnCancelAll.setTitle("Stop", for:  .normal)
        //alt beacon
        scanner?.startScanning()
        recursiveUpdate()
        txtBeaconUDID.resignFirstResponder()
        txtBeaconIdToMonitor.resignFirstResponder()
        txtMajor.text = ""
        txtMinor.text = ""
        txtBeaconUDID.text = ""
        self.showToast(message: "Started Discovering")
    }
    
    func recursiveUpdate(){
        self.getBeaconUpdates()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
            self.recursiveUpdate()
        })
    }
    
    func getBeaconUpdates(){
        if let detectedBeacons = scanner?.trackedBeacons() as? [RNLBeacon] {
                    for beacon in detectedBeacons {
                        guard let beaconTypeCode =  beacon.beaconTypeCode  else {
                            continue
                        }
                        debugPrint("beaconTypeCode: \(beaconTypeCode)")

                        guard let serviceUuid =  beacon.serviceUuid  else {
                            continue
                        }
                        debugPrint("serviceUuid: \(serviceUuid)")
                        
                        if (beacon.beaconTypeCode.intValue == 0xbeac){
                            // this is an AltBeacon
                            NSLog("Detected AltBeacon UDID: %@ Major: %@ Minor: %@", beacon.id1, beacon.id2, beacon.id3)
                            self.txtBeaconIdToMonitor.text = beacon.id1
                            let accuracy = (APPDELEGATE.calculateAccuracy(txPower: beacon.measuredPower as! Int, rssi: beacon.rssi as! Double))
                            self.lblDistance.text = "\(accuracy)"

//                            debugPrint("Accuracy:\(APPDELEGATE.calculateAccuracy(txPower: beacon.measuredPower as! Int, rssi: beacon.rssi as! Double))")
//                            debugPrint("beacon AltBeacon :\(String(describing: beacon.name)) distance:\(beacon.coreLocationAccuracy)")
                        }
                        else if (beacon.beaconTypeCode.intValue == 0x00 || beacon.serviceUuid.intValue == 0xFEAA){
                            // this is eddystone uid
                            NSLog("Detected EDDYSTONE-UID with namespace %@ instance %@", beacon.id1, beacon.id2)
                            debugPrint("beacon eddystone url :\(String(describing: beacon.name)) distance:\(beacon.coreLocationAccuracy)")
                            self.txtBeaconIdToMonitor.text = beacon.id1
                            let accuracy = (APPDELEGATE.calculateAccuracy(txPower: beacon.measuredPower as! Int, rssi: beacon.rssi as! Double))
                            self.lblDistance.text = "\(accuracy)"
                        }
                        else if (beacon.beaconTypeCode.intValue == 0x10 || beacon.serviceUuid.intValue == 0xFEAA) {
                            // this is eddystone url
                            NSLog("Detected EDDYSTONE-URL with %@", RNLURLBeaconCompressor.urlString(fromEddystoneURLIdentifier: beacon.id1))
                            debugPrint("beacon eddystone:\(String(describing: beacon.name)) distance:\(beacon.coreLocationAccuracy)")
                            self.txtBeaconIdToMonitor.text = beacon.id1
                            let accuracy = (APPDELEGATE.calculateAccuracy(txPower: beacon.measuredPower as! Int, rssi: beacon.rssi as! Double))
                            self.lblDistance.text = "\(accuracy)"

                        }
                        else {
                            // some other beacon type
                        }
                    }
                }
    }
    
    @IBAction func createBeacon(_ sender: Any){
        
        //check for UUID
        if let strUuid = txtBeaconUDID.text, !strUuid.isEmpty {
            if let uuid = UUID(uuidString: localBeaconUUID){
                localBeaconUUID = strUuid
            }else{
                self.showToast(message: "Invalid UUID")
            }
        }else{
            localBeaconUUID = SampleBeaconUUID
            txtBeaconUDID.text = localBeaconUUID
            self.showToast(message: "Using Pre-Set UUID")
        }
        
        //check for Major
        if let strMajor = txtMajor.text, !strMajor.isEmpty {
            if let major = CLBeaconMajorValue(strMajor){
                localBeaconMajor = major
            }else{
                self.showToast(message: "Invalid Major")
            }
        }else{
            localBeaconMajor = SampleBeaconMajor
            txtMajor.text = "\(localBeaconMajor)"
            self.showToast(message: "Using Pre-Set Major")
        }
        
        //check for Minor
        if let strMinor = txtMinor.text, !strMinor.isEmpty {
            if let minor = CLBeaconMinorValue(strMinor){
                localBeaconMinor = minor
            }else{
                self.showToast(message: "Invalid Minor")
            }
        }else{
            localBeaconMinor = SampleBeaconMinor
            txtMinor.text = "\(localBeaconMinor)"
            self.showToast(message: "Using Pre-Set Minor")
        }
        
        txtBeaconIdToMonitor.text = ""
        lblDistance.text = ""
        txtBeaconUDID.resignFirstResponder()
        APPDELEGATE.startAdvertising()
        btnCalculateDistance.isEnabled = false
        btnCreateBeacon.isEnabled = false
        btnCancelAll.isEnabled = true
        btnCancelAll.setTitle("Stop", for:  .normal)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        true
    }
    
    func stopEverything(){
        scanner?.stopScanning()
        APPDELEGATE.stopAdvertising()
        btnCalculateDistance.isEnabled = true
        btnCreateBeacon.isEnabled = true
        btnCancelAll.isEnabled = false
        btnCancelAll.setTitle("Beacon Demo", for:  .normal)
        txtBeaconUDID.text = ""
        txtBeaconIdToMonitor.text = ""
        lblDistance.text = ""
        txtMajor.text = ""
        txtMinor.text = ""
        txtBeaconIdToMonitor.resignFirstResponder()
    }
    
    @IBAction func cancelAll(_ sender: Any) {
        stopEverything()
    }
    
}

extension ViewController{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        return cell
    }
}


