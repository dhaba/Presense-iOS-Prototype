//
//  ConfirmationViewController.swift
//  Presence Prototype
//
//  Created by Davis Haba on 11/20/14.
//  Copyright (c) 2014 Davis Haba. All rights reserved.
//

import Foundation

class ConfirmationViewController: UIViewController {
    @IBOutlet weak var debugTextView: UITextView!
    @IBOutlet weak var toolsContainer: UIView!
    @IBOutlet weak var thanksLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        debugTextView.hidden = false
        thanksLabel.hidden = true
        //debugTextView.selectable = false
        //debugTextView.editable = false
        //debugTextView.userInteractionEnabled = true
        //debugTextView.scrollEnabled = true
        LogManager.sharedInstance.debugTextView = debugTextView
        BeaconManager.sharedInstance.startMonitoringForBeacons()

        // TODO -- Add gesture recognizers
    }

    func gestureRecognized(sender: UITapGestureRecognizer) {
        debugTextView.hidden = !debugTextView.hidden
        thanksLabel.hidden = !thanksLabel.hidden
    }

    @IBAction func outputBeaconsPressed(sender: AnyObject) {
        BeaconManager.sharedInstance.printVisibleBeacons()
    }

    @IBAction func clearPressed(sender: AnyObject) {
        debugTextView.attributedText = NSAttributedString(string: "")
    }

}
