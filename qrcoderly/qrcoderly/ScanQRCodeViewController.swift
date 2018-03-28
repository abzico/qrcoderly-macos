//
//  ScanQRCodeViewController.swift
//  qrcoderly
//
//  Created by Wasin Thonkaew on 3/28/18.
//  Copyright © 2018 Wasin Thonkaew. All rights reserved.
//

import Cocoa

class ScanQRCodeViewController: NSViewController {

    @IBOutlet weak var customView: CustomView!
    @IBOutlet weak var helpButton: NSButton!
    
    let helpPopover = NSPopover()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        self.view.wantsLayer = true
        // create and set help popover
        helpPopover.contentViewController = HelpViewController.freshController()
    }
    
    override func viewWillAppear() {
        // listen to events
        NotificationCenter.default.addObserver(self, selector: #selector(ScanQRCodeViewController.handleAppPopoverToClose(notification:)), name: NSNotification.Name(rawValue: SharedConstants.Notification.buttonItemClickPopoverToClose.rawValue), object: nil)
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
    
        // remove events
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: SharedConstants.Notification.buttonItemClickPopoverToClose.rawValue), object: nil)
    }
    
    @objc func handleAppPopoverToClose(notification: Notification) {
        // close help popover if needed
        if helpPopover.isShown {
            closeHelpPopover(sender: self)
            
            // set shared flag to let main VC knows it should handle things
            SharedVolatile.isHelpPopoverShown = true
        }
    }
    
    @IBAction func onTouchHelpButton(_ sender: Any) {
        print("touched on help button")
        
        toggleHelpPopover(sender)
    }
    
    @objc func toggleHelpPopover(_ sender: Any?) {
        if helpPopover.isShown {
            closeHelpPopover(sender: sender)
        }
        else {
            showHelpPopover(sender: sender)
        }
    }
    
    func showHelpPopover(sender: Any?) {
        helpPopover.show(relativeTo: helpButton.bounds, of: helpButton, preferredEdge: NSRectEdge.maxY)
    }
    
    func closeHelpPopover(sender: Any?) {
        helpPopover.performClose(sender)
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
