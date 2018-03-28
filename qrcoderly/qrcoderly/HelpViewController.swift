//
//  HelpViewController.swift
//  qrcoderly
//
//  Created by Wasin Thonkaew on 3/29/18.
//  Copyright © 2018 Wasin Thonkaew. All rights reserved.
//

import Cocoa

class HelpViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
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
