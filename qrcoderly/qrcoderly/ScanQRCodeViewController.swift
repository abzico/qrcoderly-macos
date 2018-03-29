//
//  ScanQRCodeViewController.swift
//  qrcoderly
//
//  Created by Wasin Thonkaew on 3/28/18.
//  Copyright © 2018 Wasin Thonkaew. All rights reserved.
//

import Cocoa
import AVFoundation

class ScanQRCodeViewController: NSViewController {

    @IBOutlet weak var customView: CustomView!
    @IBOutlet weak var helpButton: NSButton!
    
    let helpPopover = NSPopover()
    
    // MARK: AVFoundataion for iSight camera
    var session: AVCaptureSession!
    var videoCompression: AVCaptureConnection?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        // we will work with layer, thus request to have it here
        self.view.wantsLayer = true
        
        // create and set help popover
        helpPopover.contentViewController = HelpViewController.freshController()
        
        // set up avfoundation to capture video and show preview on child view layer
        initCaptureSession()
        setupPreviewLayer()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        // listen to events
        NotificationCenter.default.addObserver(self, selector: #selector(ScanQRCodeViewController.handleAppPopoverToClose(notification:)), name: NSNotification.Name(rawValue: SharedConstants.Notification.buttonItemClickPopoverToClose.rawValue), object: nil)
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
    
        // remove events
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: SharedConstants.Notification.buttonItemClickPopoverToClose.rawValue), object: nil)
        
        // stop monitoring to not use cpu usage too much while its VC is not active
        stopVideoPreview()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        // start monitoring
        startVideoPreview()
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

// MARK: AVFoundatioan implementation
extension ScanQRCodeViewController {
    func initCaptureSession() {
        session = AVCaptureSession()
        
        if session.canSetSessionPreset(.high) {
            session.canSetSessionPreset(.high)
        }
        
        let captureDevice = AVCaptureDevice.default(for: .video)
        
        if let captureDevice = captureDevice {
            do {
                let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            
                if session.canAddInput(deviceInput) {
                    session.addInput(deviceInput)
                }
            } catch {
                print("error creating deviceInput")
            }
        }
        else {
            print("error check captureDevice whether it's created normally")
        }
    }
    
    func setupPreviewLayer() {
        if session != nil {
            previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
            previewLayer!.frame = customView.frame
            
            // layer must be there as result of setWantsLayer
            view.layer!.addSublayer(previewLayer!)
        }
    }
    
    func startVideoPreview() {
        if !session.isRunning {
            session.startRunning()
        }
    }
    
    func stopVideoPreview() {
        if session.isRunning {
            session.stopRunning()
        }
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
