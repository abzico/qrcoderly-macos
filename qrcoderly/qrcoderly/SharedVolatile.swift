//
//  SharedVolatile.swift
//  qrcoderly
//
//  Created by Wasin Thonkaew on 3/29/18.
//  Copyright © 2018 Wasin Thonkaew. All rights reserved.
//

import Foundation

final class SharedVolatile {
    /**
     Flag to be managed by ScanQRCodeViewController when it receives notification of SharedConstants.Notification.buttonItemClickPopoverToClose to let AppDelegate knows whether it should delay execution of code closing app popover.
     
     As well when AppDelegate checks this flag, and operate on it. It should reset flag (setting as false).
    */
    public static var isHelpPopoverShown: Bool = false
}
