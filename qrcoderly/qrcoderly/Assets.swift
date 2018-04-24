//
//  Assets.swift
//  qrcoderly
//
//  Created by Wasin Thonkaew on 4/24/18.
//  Copyright © 2018 Wasin Thonkaew. All rights reserved.
//

import Foundation

final class Assets {
    /**
     QRScan beep sfx. Cached for performance.
    */
    public static let qrscanBeepSfx = {
       return Bundle.main.url(forResource: "beep", withExtension: "wav")!
    }()
}
