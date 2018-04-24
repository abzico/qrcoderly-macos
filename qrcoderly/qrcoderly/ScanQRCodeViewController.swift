//
//  ScanQRCodeViewController.swift
//  qrcoderly
//
//  Created by Wasin Thonkaew on 3/28/18.
//  Copyright © 2018 Wasin Thonkaew. All rights reserved.
//

import Cocoa
import AVFoundation

class ScanQRCodeViewController: NSViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    @IBOutlet weak var customView: CustomView!
    @IBOutlet weak var helpButton: NSButton!
    @IBOutlet weak var resultTextField: NSTextField!
    
    let helpPopover = NSPopover()
    
    // MARK: AVFoundataion for iSight camera
    var session: AVCaptureSession!
    var videoCompression: AVCaptureConnection?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var overlayLayer: CAShapeLayer?
    var qrcodeDetector: CIDetector?
    
    var previouslyMessageStringDetected: String?
    var isOkToOpenNativeBrowserTabAgainIfMessageStringIsTheSame: Bool = true
    
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
        setupOverlayLayer()
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
                
                // create qrcode detector
                let options = [CIDetectorAccuracy: CIDetectorAccuracyLow]
                qrcodeDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: options)
                
                // make a video data output
                let videoDataOutput = AVCaptureVideoDataOutput()
                let rgbOutputSettings:[String:Any] = [kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCMPixelFormat_32BGRA)]
                videoDataOutput.videoSettings = rgbOutputSettings
                videoDataOutput.alwaysDiscardsLateVideoFrames = true
                
                // create a serial dispatch queue to process sample buffer
                let queue = DispatchQueue(label: "videoDataBufferSerialQueue")
                videoDataOutput.setSampleBufferDelegate(self, queue: queue)
                if session.canAddOutput(videoDataOutput) {
                    session.addOutput(videoDataOutput)
                }
                // get the output for doing face detection
                videoDataOutput.connection(with: AVMediaType.video)!.isEnabled = true
                
            } catch {
                fatalError("error creating deviceInput")
            }
        }
        else {
            fatalError("error check captureDevice whether it's created normally")
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
    
    func setupOverlayLayer() {
        if session != nil {
            overlayLayer = CAShapeLayer()
            overlayLayer!.lineWidth = 2
            overlayLayer!.strokeColor = NSColor.yellow.cgColor
            overlayLayer!.fillColor = NSColor.clear.cgColor
            // note: for the paths we will update it real-time when it's started and we detecte rectangular shape in video stream
            
            view.layer!.addSublayer(overlayLayer!)
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // get the image
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        let attachments:[String:Any] = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate) as! [String : Any]
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer!, options: attachments)
        
        detectQRCode(ciImage)
    }
    
    func detectQRCode(_ ciImage: CIImage) {
        guard let detector = qrcodeDetector else { return }
        
        // also apply orientation of image to detection
        var options: [String:Any]
        if ciImage.properties.keys.contains((kCGImagePropertyOrientation as String)) {
            options = [CIDetectorImageOrientation: ciImage.properties[(kCGImagePropertyOrientation as String)] ?? 1]
        }
        else {
            options = [CIDetectorImageOrientation: 1]
        }
        
        // find features
        let features = detector.features(in: ciImage, options: options)
        
        #if DEBUG
        print("detect qrcode got features: \(features.count)")
        #endif
        
        if features.count > 0 {
            let qrcodeFeature = features.first as! CIQRCodeFeature
            #if DEBUG
            print("bounds for 1st feature: \(qrcodeFeature.bounds)")
            #endif
            
            #if DEBUG
            // find the message of qrcode
            print("message in qrcode: " + (qrcodeFeature.messageString ?? "empty"))
            #endif
            
            // if we found message baked with qrcode then we continue our operation
            if let messageString = qrcodeFeature.messageString {
                // if deteced message string is not the same as previously detected, thus we go ahead
                // note entire messageString represents all URLs that we might open new browser tabs
                if previouslyMessageStringDetected == nil ||
                    (previouslyMessageStringDetected != nil && messageString != previouslyMessageStringDetected) ||
                    (previouslyMessageStringDetected != nil && messageString == previouslyMessageStringDetected && isOkToOpenNativeBrowserTabAgainIfMessageStringIsTheSame) {
                    
                    // play beep sfx
                    AudioPlayer.shared.play(Assets.qrscanBeepSfx)
                    
                    // open URLs via native browser
                    let urls = findAllURLs(messageString)
                    if urls.count > 0 {
                        // update result textfield
                        DispatchQueue.main.async {
                            self.resultTextField.stringValue = messageString
                        }
                        
                        // loop through all urls then open a new browser tap
                        for url in urls {
                            // set flag that we've used the chance to open browser tabs this time
                            isOkToOpenNativeBrowserTabAgainIfMessageStringIsTheSame = false
                            
                            // open a new browser tab
                            NSWorkspace.shared.open(URL(string: url)!)
                        }
                        
                        // for dispatched queue execution code
                        let tempURL = messageString
                        
                        // schedule to make it ok to open browser tab again after cooldown time
                        DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + Settings.COOLDOWN_UNTIL_OPEN_NEW_BROWSER_TAB) {
                            // check only if such message is the same as previuosly, so we gonna allow openning a new tab again
                            // this is to prevent mess state as user can immediately scan a new qrcode (thus new URL)
                            if self.previouslyMessageStringDetected != nil && tempURL == self.previouslyMessageStringDetected {
                                self.isOkToOpenNativeBrowserTabAgainIfMessageStringIsTheSame = true
                                #if DEBUG
                                print("set ok to open a new tab again")
                                #endif
                            }
                        }
                    }
                        // just show result on UI
                    else {
                        DispatchQueue.main.async {
                            self.resultTextField.stringValue = messageString
                        }
                    }
                }
                
                // update detected message string
                previouslyMessageStringDetected = messageString
            }
        }
    }
    
    // Solution from https://www.hackingwithswift.com/example-code/strings/how-to-detect-a-url-in-a-string-using-nsdatadetector
    // Adapted and modified to return array of matched url
    // Find all urls inside input string, then return array of such matched urls
    private func findAllURLs(_ urlString: String) -> [String] {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: urlString, options: [], range: NSRange(location: 0, length: urlString.utf16.count))
        
        var urls:[String] = []
        
        for match in matches {
            guard let range = Range(match.range, in: urlString) else { continue }
            urls.append(String(urlString[range]))
        }
        
        return urls
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
