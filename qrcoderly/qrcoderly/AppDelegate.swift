//
//  AppDelegate.swift
//  qrcoderly
//
//  Created by Wasin Thonkaew on 3/28/18.
//  Copyright © 2018 Wasin Thonkaew. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    let popover = NSPopover()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        if let button = statusItem.button {
            button.image = NSImage(named: NSImage.Name("statusbaricon"))
            button.action = #selector(AppDelegate.togglePopover(_:))
        }
        popover.contentViewController = ScanQRCodeViewController.freshController()
        
        //constructMenu()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @objc func togglePopover(_ sender: Any?) {
        if popover.isShown {
            // send notification to allow others to handle something first
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: SharedConstants.Notification.buttonItemClickPopoverToClose.rawValue), object: nil)
            
            // at least wait for very short time to allow other VC to set flag
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.04) {
                if SharedVolatile.isHelpPopoverShown {
                    // wait long time to close app popover
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        self.closePopover(sender: sender)
                        
                        // reset the flag
                        SharedVolatile.isHelpPopoverShown = false
                    })
                }
                else {
                    // immediately close popover
                    self.closePopover(sender: sender)
                }
            }
        }
        else {
            showPopover(sender: sender)
        }
    }
    
    func showPopover(sender: Any?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }
    
    func closePopover(sender: Any?) {
        popover.performClose(sender)
    }
    
    func constructMenu() {
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Scan QRCode", action: #selector(scanQRCode(_:)), keyEquivalent: "s"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    @objc func scanQRCode(_ sender: Any?) {
        
    }
}

