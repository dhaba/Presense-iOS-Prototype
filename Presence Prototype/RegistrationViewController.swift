
//
//  RegistrationViewController.swift
//  Presence Prototype
//
//  Created by Davis Haba on 11/18/14.
//  Copyright (c) 2014 Davis Haba. All rights reserved.
//

import UIKit

class RegistrationViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var deviceModelPicker: UIPickerView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    let deviceModels = ["iPhone 4s", "iPhone 5", "iPhone 5s", "iPhone 6", "iPhone 6 Plus"]
    var isSubmitting = false

    // MARK: UIViewControllerDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        deviceModelPicker.dataSource = self
        deviceModelPicker.delegate = self
        deviceModelPicker.selectRow(2, inComponent: 0, animated: false)
        nameTextField.delegate = self
        activityIndicator.hidesWhenStopped = true;
        activityIndicator.stopAnimating()

        BeaconManager.sharedInstance.requestUserPermissionsIfNecessary()
    }

    // MARK: UITextFieldDelegate

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }

    // MARK: UIPickerViewDataSource and Delegate

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (component == 0) {
            return deviceModels.count
        }
        return 0
    }

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        assert(component == 0, "Tried to get pickerview row for a compontent that was not 0! component = \(component)")
        return deviceModels[row];
    }

    // MARK: IBActions

    @IBAction func submitButtonPressed(sender: AnyObject) {
        if isSubmitting {
            return
        }

        isSubmitting = true
        activityIndicator.startAnimating()
        RestManager.sharedInstance.registerUser(nameTextField.text, deviceModel: deviceModels[deviceModelPicker.selectedRowInComponent(0)],
            completionHandler: { [unowned self] (success, response) -> () in
                self.activityIndicator.stopAnimating()
                self.isSubmitting = false
                if success {
                    self.performSegueWithIdentifier("SegueToConfirmationViewController", sender: self)
                } else {
                    let alert = UIAlertController(title: "Error Registering User", message: "There was a problem registering the user. Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
        })
    }

    // MARK: Private
}

