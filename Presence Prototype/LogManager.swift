//
//  LogManager.swift
//  Presence Prototype
//
//  Created by Davis Haba on 11/20/14.
//  Copyright (c) 2014 Davis Haba. All rights reserved.
//

import Foundation

struct LogCommand {
    let text: String
    let color: UIColor
}

class LogManager {
    class var sharedInstance: LogManager {
    struct Singleton {
        static let instance = LogManager()
        }
        return Singleton.instance
    }

    var debugTextView: UITextView? {
        didSet {
            if let tv = debugTextView {
                // Clear text and apply log
                setupTextView(tv)
            }
        }
    }
    var timeStamp: String {
        return dateFormater.stringFromDate(NSDate())
    }

    let dateFormater = NSDateFormatter()
    let maxSizeMultiplier: CGFloat = 12.5
    let fontSize: CGFloat = 12.0

    private var missedLogs: [LogCommand] = []

    init() {
        dateFormater.dateFormat = "hh:mm:ss a"
    }

    func debugLog(text: String) {
        appendText("[DEBUG] \(text)", color: UIColor.whiteColor())
    }

    func restLog(text: String) {
        appendText("[REST] \(timeStamp): \(text)", color: UIColor.redColor())
    }

    func appLog(text: String) {
        appendText("[APP] \(timeStamp): \(text)", color: UIColor.orangeColor())
    }

    func beaconLog(text: String) {
        appendText("[BEACON] \(timeStamp): \(text)", color: UIColor.greenColor())
    }

    private func appendText(text: String, color: UIColor) {
        println(text)
        if let textView = debugTextView {
            // Add to text view
            let textToAppend = NSAttributedString(string: "\(text)\n", attributes: [NSForegroundColorAttributeName: color, NSFontAttributeName: UIFont.systemFontOfSize(fontSize)])
            let newText = NSMutableAttributedString(attributedString: textView.attributedText)
            newText.appendAttributedString(textToAppend)
            textView.attributedText = newText

            // Clear text view if its too long
            if (textView.contentSize.height > textView.frame.size.height * maxSizeMultiplier) {
                textView.attributedText = NSAttributedString(string: "")
            }

            // Scroll to bottom of text view
            //textView.scrollEnabled = false
            textView.scrollRangeToVisible(NSRange(location: textView.attributedText.length, length: 0))
            //textView.scrollEnabled = true
        } else {
            // Save it to the list
            missedLogs.append(LogCommand(text: text, color: color))
        }
    }

    private func setupTextView(textView: UITextView) {
        println("Configuring text view...")
        textView.attributedText = NSAttributedString(string: "")
        while !missedLogs.isEmpty {
            let lastLog = missedLogs.removeLast()
            appendText(lastLog.text, color: lastLog.color)
        }
    }

}