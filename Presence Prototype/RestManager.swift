//
//  RestManager.swift
//  Presence Prototype
//
//  Created by Davis Haba on 11/19/14.
//  Copyright (c) 2014 Davis Haba. All rights reserved.
//

import Foundation

class RestManager {
    class var sharedInstance: RestManager {
        struct Singleton { static let instance = RestManager() }
        return Singleton.instance
    }

    private let afManager: AFHTTPRequestOperationManager
    private let deviceUUID: String
    private let Token = "secret"
    private let ApiBaseUrl = "http://polar-bastion-7566.herokuapp.com/api"
//    private let ApiBaseUrl = "http://localhost:3000/api"

    init() {
        // Set device UUID in UserDefaults if not already set
        let userDefaults =  NSUserDefaults.standardUserDefaults()
        if let storedUUID = userDefaults.objectForKey(UserIdentificationKey) as? String {
            deviceUUID = storedUUID
        } else {
            deviceUUID = UIDevice.currentDevice().identifierForVendor.UUIDString
            userDefaults.setObject(deviceUUID, forKey:UserIdentificationKey)
            userDefaults.synchronize()
        }

        // Configure afManager
        afManager = AFHTTPRequestOperationManager()
        afManager.requestSerializer = AFJSONRequestSerializer() as AFJSONRequestSerializer;
        afManager.requestSerializer.setValue("Token token=\(Token)", forHTTPHeaderField: "Authorization")
    }

    func registerUser(name: String, deviceModel: String, completionHandler: (success: Bool, response: AnyObject?) -> ()) {
        afManager.POST(ApiBaseUrl.stringByAppendingPathComponent("users"),
            parameters: ["name": name, "device_uuid": deviceUUID, "device_model": deviceModel],
            success: { (requestOperation, response) -> Void in
                RestLog("Success registering user, response: \(response)");
                let userDefaults = NSUserDefaults.standardUserDefaults()
                userDefaults.setBool(true, forKey:UserDidRegisterKey)
                userDefaults.synchronize()
                completionHandler(success: true, response: response)
            }) { (requestOperation, error) -> Void in
                RestLog("Error registering user, error: \(error)")
                completionHandler(success: false, response: error)
        }
    }

    func postBeaconEvent(beaconEvent: BeaconEvent) {
        let params: [String: String] = ["device_uuid": deviceUUID, "beacon_uuid": beaconEvent.beacon.uuid,
            "beacon_major": "\(beaconEvent.beacon.major)", "beacon_minor": "\(beaconEvent.beacon.minor)", "rssi": "\(beaconEvent.beacon.rssi)",
            "event_type": beaconEvent.eventType.rawValue, "time_received": beaconEvent.timestamp.description]

        afManager.POST(ApiBaseUrl.stringByAppendingPathComponent("beacon_events"),
            parameters: params,
            success: { (requestOperation, response) -> Void in
                RestLog("Success POSTing beacon event, response: \(response)");
            }) { (requestOperation, error) -> Void in
                RestLog("Error POSTing beacon event, params: \(params)")
        }
    }

}