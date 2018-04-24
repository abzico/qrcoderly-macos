//
//  HelpViewController.swift
//  qrcoderly
//
//  Created by Wasin Thonkaew on 3/29/18.
//  Copyright © 2018 Wasin Thonkaew. All rights reserved.
//

import Cocoa

class HelpViewController: NSViewController {

    @IBOutlet weak var textField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        // detect darkmode
        self.updateUI(darkMode: Util.getIsDarkMode())
        
        // bot are needed, otherwise hyperlink won't accept mousedown
        self.textField.allowsEditingTextAttributes = true
        self.textField.isSelectable = true
    }
    
    func updateUI(darkMode: Bool) {
        // set url for part of string inside text field
        let attrString = NSMutableAttributedString(string: "Made with ❤️ by @haxpor", attributes: [NSAttributedStringKey.font : NSFont.boldSystemFont(ofSize: 13)])
        let rangeForURL = NSMakeRange(16, 7)  // to cover @haxpor
        let rangeNormal = NSMakeRange(0, attrString.length-7)   // to cover the less
        attrString.beginEditing()
        // attributes for @haxpor
        attrString.addAttribute(NSAttributedStringKey.link, value: NSURL(string: "https://twitter.com/haxpor")!.absoluteString!, range: rangeForURL)
        attrString.addAttribute(NSAttributedStringKey.foregroundColor, value: NSColor.blue, range: rangeForURL)
        attrString.addAttribute(NSAttributedStringKey.underlineStyle, value: NSNumber(value: Int8(NSUnderlineStyle.styleSingle.rawValue)), range: rangeForURL)
        // attributes for the less of the text
        if darkMode {
            // dark theme
            attrString.addAttribute(NSAttributedStringKey.foregroundColor, value: NSColor.white, range: rangeNormal)
        }
        else {
            // normal theme
            attrString.addAttribute(NSAttributedStringKey.foregroundColor, value: NSColor.black, range: rangeNormal)
        }
        attrString.endEditing()
        
        // set attributed string to text field
        self.textField.attributedStringValue = attrString
    }
}

extension HelpViewController {
    // MARK: Storyboard instantiation
    static func freshController() -> HelpViewController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier(rawValue: "HelpViewController")
        guard let viewController = storyboard.instantiateController(withIdentifier: identifier) as? HelpViewController else {
            fatalError("Cannot find HelpViewConroller. Check Main.storyboard")
        }
        return viewController
    }
}
