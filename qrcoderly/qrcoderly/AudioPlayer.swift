//
//  AudioPlayer.swift
//  qrcoderly
//
//  Created by Wasin Thonkaew on 4/24/18.
//  Copyright © 2018 Wasin Thonkaew. All rights reserved.
//

import Foundation
import AVFoundation

class AudioPlayer {
    static let shared = AudioPlayer()
    
    // to not let ARC release our player object at the time of playing audio
    private var player: AVAudioPlayer?
    
    private init() {}
    
    /**
     Play audio from input URL.
     
     - Parameter url: URL of content to be played
    */
    func play(_ url: URL) {
        do {
            player = try AVAudioPlayer(contentsOf: url)
            guard let _player = player else {
                #if DEBUG
                print("error in initializing player to player audio")
                #endif
                
                return
            }
            
            _player.prepareToPlay()
            _player.play()
        } catch let error {
            #if DEBUG
            print("error in initializing player to player audio: " + error.localizedDescription)
            #endif
        }
    }
}
