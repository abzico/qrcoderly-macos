//
//  ScanQRCodeViewController.swift
//  qrcoderly
//
//  Created by Wasin Thonkaew on 3/28/18.
//  Copyright © 2018 Wasin Thonkaew. All rights reserved.
//

import Cocoa

class ScanQRCodeViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}

extension ScanQRCodeViewController {
    // MARK: Storyboard instantiation
    static func freshController() -> ScanQRCodeViewController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier(rawValue: "ScanQRCodeViewController")
        guard let viewController = storyboard.instantiateController(withIdentifier: identifier) as? ScanQRCodeViewController else {
            fatalError("Cannot find ScanQRCodeViewController. Check Main.storyboard")
        }
        return viewController
    }
}
