// Playground - noun: a place where people can play

import UIKit


enum BeaconEventType: String {
    case Enter = "enter", Exit = "exit", Range = "range"
}

struct Beacon: Printable {

    let uuid: String
    let major: NSNumber
    let minor: NSNumber
    var rssi: Int?
    var description: String {
        return "UUID: \(uuid), Major: \(major), Minor: \(minor)"
    }

//    init(beacon: CLBeacon) {
//        uuid = beacon.proximityUUID.UUIDString
//        major = beacon.major
//        minor = beacon.minor
//    }

}

var beacon = Beacon(uuid: "12345", major: 0, minor: 0, rssi: -75)

println("valueeee of beacon: \(beacon)")







