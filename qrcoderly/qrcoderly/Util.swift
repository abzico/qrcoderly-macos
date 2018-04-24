//
//  Util.swift
//  qrcoderly
//
//  Created by Wasin Thonkaew on 4/25/18.
//  Copyright © 2018 Wasin Thonkaew. All rights reserved.
//

import Foundation

class Util {
    
    /**
    Check whether it's dark mode or not.
     
     - Returns: True for dark mode, otherwise return false for normal mode.
    */
    static func getIsDarkMode() -> Bool {
        if let darkMode = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") {
            if darkMode == "Dark" {
                return true
            }
            else {
                return false
            }
        }
        else {
            return false
        }
    }
}
