//
//  ViewController.swift
//  BroadcastReceiverBeacon
//
//  Created by Anand Upadhyay on 28/08/24.
//

import UIKit

import Foundation
import UserNotifications


class ViewController: UIViewController, UITextFieldDelegate,UNUserNotificationCenterDelegate {

    
    @IBOutlet weak var txtBeaconIdToMonitor: UITextField!
    @IBOutlet weak var txtBeaconUDID: UITextField!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var btnCreateBeacon: UIButton!
    
    @IBOutlet weak var btnCalculateDistance: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        APPDELEGATE.viewController = self
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            debugPrint("Monitoring Region:\(APPDELEGATE.locationManager.monitoredRegions)")
        })
        
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
        // Do any additional setup after loading the view.
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken
        deviceToken: Data)
    {
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error:Error) {
        
    }
   
    @IBAction func calculateDistance(_ sender: Any){
        APPDELEGATE.startScanning()
        btnCreateBeacon.isEnabled = false
        btnCalculateDistance.isEnabled = false
    }
    
    @IBAction func createBeacon(_ sender: Any){
        APPDELEGATE.initLocalBeacon()
        btnCalculateDistance.isEnabled = false
        btnCreateBeacon.isEnabled = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        true
    }
    
}

extension ViewController{
   
}


