//
//  AppDelegate.swift
//  BroadcastReceiverBeacon
//
//  Created by Anand Upadhyay on 28/08/24.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
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
 
 Beacon Distance
 https://stackoverflow.com/questions/20416218/understanding-ibeacon-distancing/20434019#20434019
 https://www.hackingwithswift.com/example-code/location/how-to-detect-ibeacons
 Distance in Proximity https://www.hackingwithswift.com/read/22/3/hunting-the-beacon-clbeaconregion
 
 
 Reconnecting with BLE Device if App is terminated
 https://blog.grio.com/2023/03/ibeacon-reconnecting-an-ios-app-to-a-bluetooth-device-if-the-app-is-terminated.html
 
 
 Beacon Notification Looping instead of Showing Once
 https://www.hackingwithswift.com/forums/swift/ibeacon-app-problem-with-notifications-looping-instead-of-showing-just-once/2158
 
 
 */
