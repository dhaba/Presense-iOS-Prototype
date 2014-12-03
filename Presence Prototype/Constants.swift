//
//  Constants.swift
//  Presence Prototype
//
//  Created by Davis Haba on 11/19/14.
//  Copyright (c) 2014 Davis Haba. All rights reserved.
//

import Foundation

// Global Constants
let UserIdentificationKey = "user_id_key"
let UserDidRegisterKey = "user_did_register_key"

// Global functions
func DebugLog(text: String) { LogManager.sharedInstance.debugLog(text) }
func RestLog(text: String) { LogManager.sharedInstance.restLog(text) }
func AppLog(text: String) { LogManager.sharedInstance.appLog(text) }
func BeaconLog(text: String) { LogManager.sharedInstance.beaconLog(text) }
