//
//  SimulatBeacon.swift
//  BroadcastReceiverBeacon
//
//  Created by Anand Upadhyay on 28/08/24.
//

import Foundation
import CoreBluetooth
import CoreLocation
import UIKit

class BeaconTransmitter: NSObject, CBPeripheralManagerDelegate {
    var region: CLBeaconRegion?
    var on = false
    var _peripheralManager: CBPeripheralManager?
    var peripheralManager: CBPeripheralManager {
        if _peripheralManager == nil {
            _peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        }
        return _peripheralManager!
    }
    override init() {
        super.init()
    }
    
    func stop() {
        on = false
        peripheralManager.stopAdvertising()
    }
    
    func start(region: CLBeaconRegion) {
        on = true
        self.region = region
        startTransmitting()
    }
    
    func startTransmitting() {
        if let region = region {
            let peripheralData = region.peripheralData(withMeasuredPower: -59) as Dictionary
            peripheralManager.stopAdvertising()
            peripheralManager.startAdvertising(peripheralData as? [String : AnyObject])
        }
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if(peripheral.state == .poweredOn) {
            if on {
                startTransmitting()
            }
        }
        else if(peripheral.state == .poweredOff) {
            NSLog("Bluetooth is off")
        }
        else if(peripheral.state == .unsupported) {
            NSLog("Bluetooth not supported")
        }
    }
}
