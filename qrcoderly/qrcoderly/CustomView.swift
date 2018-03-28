//
//  CustomView.swift
//  qrcoderly
//
//  Created by Wasin Thonkaew on 3/29/18.
//  Copyright © 2018 Wasin Thonkaew. All rights reserved.
//

import Cocoa

class CustomView: NSView {
    
    let backgroundColor = NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0.5)
    let borderColor = NSColor(calibratedRed: 1, green: 1, blue: 1, alpha: 0.6)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        setup()
    }
    
    func setup() {
        self.wantsLayer = true
        
        // set to have border color
        if self.layer != nil {
            self.layer!.borderColor = borderColor.cgColor
            self.layer!.borderWidth = 1.0
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        backgroundColor.setFill()
        dirtyRect.fill()
    }
}
