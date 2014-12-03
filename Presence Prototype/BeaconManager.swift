//
//  BeaconManager.swift
//  Presence Prototype
//
//  Created by Davis Haba on 11/21/14.
//  Copyright (c) 2014 Davis Haba. All rights reserved.
//

import Foundation
import CoreLocation

// MARK: Beacon Structs
struct Beacon: Equatable, Printable {

    let uuid: String
    let major: NSNumber
    let minor: NSNumber
    var rssi: Int?

    var description: String {
        return "UUID: \(uuid), Major: \(major), Minor: \(minor), RSSI: \(rssi)"
    }

    init(beacon: CLBeacon) {
        uuid = beacon.proximityUUID.UUIDString
        major = beacon.major
        minor = beacon.minor
    }

}

func ==(lhs: Beacon, rhs: Beacon) -> Bool {
    return (lhs.uuid == rhs.uuid) && (lhs.major == rhs.major) && (lhs.minor == rhs.minor)
}

struct BeaconEvent {

    enum BeaconEventType: String {
        case Enter = "enter", Exit = "exit", Range = "range"
    }

    let beacon: Beacon
    let eventType: BeaconEventType
    let timestamp: NSDate

    init(beacon: Beacon, eventType: BeaconEventType, timestamp: NSDate) {
        self.beacon = beacon
        self.eventType = eventType
        self.timestamp = timestamp
    }

    init(beacon: Beacon, eventType: BeaconEventType) {
        self.init(beacon: beacon, eventType: eventType, timestamp: NSDate())
    }

}

// MARK: BeaconManager
class BeaconManager: NSObject {

    enum ImplementationSetting {
        case A, B // A uses multiple uuids, B ranges every n seconds
    }

    // Workaround to create a class variable
    private struct SubStruct { static var staticVariable: ImplementationSetting = .A }
    class var implementationSetting: ImplementationSetting {
        get { return SubStruct.staticVariable }
        set { SubStruct.staticVariable = newValue }
    }

    // Singleton instance. Returns the appropriate implementation defined by the implementationSetting class variable
    class var sharedInstance: BeaconManager {
        struct Singleton {
            static var instanceA: BeaconManager?
            static var instanceB: BeaconManager?
        }

        switch implementationSetting {
        case .A:
            Singleton.instanceB = nil
            if Singleton.instanceA == nil { Singleton.instanceA = BeaconManagerA() }
            return Singleton.instanceA!
        case .B:
            Singleton.instanceA = nil
            if Singleton.instanceB == nil { Singleton.instanceB = BeaconManagerB() }
            return Singleton.instanceB!
        }
    }

    private let locationManager = CLLocationManager()
    private var visibleBeacons: [String: [Beacon]] = [:] // Key is region UUID, value is array of beacons visible it that region
    private let validUUIDs: [String] = ["ABE0A3D0-971C-4418-9ECF-E2D1ABCB66BE", "45FB2AE1-A73B-4ECC-852D-DB5BDFCB4F1C"] // Groupon, Swarm Prod

    override init() {
        super.init()
        for uuid in validUUIDs {
            visibleBeacons[uuid] = []
        }
    }

    func requestUserPermissionsIfNecessary() {
        DebugLog("Currrent location permission permission value: \(CLLocationManager.authorizationStatus().rawValue)")
        if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.Authorized {
            DebugLog("Requesting always authorize location permission")
            locationManager.requestAlwaysAuthorization()
        }
    }

    func startMonitoringForBeacons() {
        if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.Authorized {
            DebugLog("!!! PROBLEM, Cannot start monitoring for beacons because we do not have the required permissions")
            return
        }

        for uuid in validUUIDs {
            BeaconLog("Started monitoring region /w UUID: \(uuid)")
            let region = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: uuid), identifier: uuid) // note identifier is same as prox uuid
            locationManager.startMonitoringForRegion(region)
            locationManager.requestStateForRegion(region)
        }
    }

    func printVisibleBeacons() {
        var logText = "\n=== Visible Beacons ==="
        for (uuid, beacons) in visibleBeacons {
            logText += "\nRegion \(uuid)"
            if (beacons.count == 0) {
                logText += "\n\tNone"
            } else {
                for beacon in beacons {
                    logText += "\n\t- major: \(beacon.major), minor: \(beacon.minor)"
                }
            }
        }
        logText += "\n====================="
        BeaconLog(logText)
    }
}

// MARK: BeaconManagerA (Multiple UUIDs solution)
class BeaconManagerA: BeaconManager, CLLocationManagerDelegate {

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        BeaconLog(">> Did ENTER region with id: \(region?.identifier?)")
    }

    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        BeaconLog("<< Did EXIT region with id: \(region?.identifier?)")
    }

    func locationManager(manager: CLLocationManager!, didDetermineState state: CLRegionState, forRegion region: CLRegion!) {
        if region == nil || region.identifier == nil {
            BeaconLog("!!! PROBLEM, region or region.identifier is nil in didDetermineState. Region: \(region), region.identifier: \(region?.identifier) ")
            return
        }

        if state != .Unknown {
            let region = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: region.identifier!), identifier: region.identifier!)
            locationManager.startRangingBeaconsInRegion(region)
            BeaconLog("++ Started ranging for region with id: \(region.identifier!)")
        }
    }

    func locationManager(manager: CLLocationManager!, monitoringDidFailForRegion region: CLRegion!, withError error: NSError!) {
        BeaconLog("!!! Monitoring failed for region with id: \(region?.identifier?) -- Error: \(error?)")
    }

    func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
        // Get list of beacons
        var currentBeacons: [Beacon] = []
        for beacon in beacons {
            if let beac = beacon as? CLBeacon {
                currentBeacons.append(Beacon(beacon: beac))
                BeaconLog("ranged beacon: \(currentBeacons.last)")
            }
        }
        currentBeacons = currentBeacons.unique()
        let previousBeacons: [Beacon] = visibleBeacons[region.identifier!]!

        // Seperate newly encountered beacons vs left behind "old" beacons. Report both sets
        let newBeacons: [Beacon] = currentBeacons.difference(previousBeacons)
        let oldBeacons: [Beacon] = previousBeacons.difference(currentBeacons)
        visibleBeacons[region.identifier!] = currentBeacons
        for beacon in newBeacons {
            BeaconLog("Posting event for NEW (didEnter) beacon: \(beacon)")
            RestManager.sharedInstance.postBeaconEvent(BeaconEvent(beacon: beacon, eventType: .Enter))
        }
        for beacon in oldBeacons {
            BeaconLog("Posting event for OLD (didExit) beacon: \(beacon)")
            RestManager.sharedInstance.postBeaconEvent(BeaconEvent(beacon: beacon, eventType: .Exit))
        }

        locationManager.stopRangingBeaconsInRegion(region)
        BeaconLog("-- Stopped ranging for region with id: \(region.identifier!)")
    }

}

// MARK: BeaconManagerB (Range every n steps/seconds)
class BeaconManagerB: BeaconManager, CLLocationManagerDelegate {

    override init() {
        super.init()
        locationManager.delegate = self
    }
}
