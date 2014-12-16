//
//  ViewController.swift
//  TrackDeckTest
//
//  Created by Jochen Bieler on 15.12.14.
//  Copyright (c) 2014 Jochen Bieler. All rights reserved.
//
import AVFoundation
import Cocoa

class ViewController: NSViewController {
    
    // Setup engine and node instances
    var engine = AVAudioEngine()
    var player = AVAudioPlayerNode()
    var delay = AVAudioUnitDelay()
    var reverb = AVAudioUnitReverb()
    var eq = AVAudioUnitEQ(numberOfBands: 2)
    
    var mixer: AVAudioMixerNode {
        get {
            return engine.mainMixerNode
        }
    }
    
    var output: AVAudioOutputNode {
        get {
            return engine.outputNode
        }
    }
    
    var format: AVAudioFormat {
        get {
            return mixer.outputFormatForBus(0)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        engine.attachNode(player)
        engine.attachNode(reverb)
        engine.attachNode(eq)
        
        
        engine.connect(player, to: eq, format: format)
        engine.connect(eq, to: reverb, format: format)
        engine.connect(reverb, to: mixer, format: format)
        
        reverb.wetDryMix = 0
        
        var filterParams = eq.bands[0] as AVAudioUnitEQFilterParameters
        filterParams.filterType = AVAudioUnitEQFilterType.HighPass
        filterParams.frequency = 0.0 // LOWS KNOB
        filterParams.gain = 1
        filterParams.bypass = false
        
        filterParams = eq.bands[1] as AVAudioUnitEQFilterParameters
        filterParams.filterType = AVAudioUnitEQFilterType.LowPass
        filterParams.frequency = 16000 //HIGHS KNOB
        filterParams.gain = 1
        filterParams.bypass = false
        
        var error:NSError?
        engine.startAndReturnError(&error)
    
        
        // load loop
        let trackURL = NSBundle.mainBundle().URLForResource("drum loop", withExtension: "wav")
        let track = AVAudioFile(forReading: trackURL, error: &error)
    
        var audioBuffer = AVAudioPCMBuffer(PCMFormat: track.processingFormat, frameCapacity: UInt32(track.length))
        track.readIntoBuffer(audioBuffer, error: nil)
        
        // trigger playback
        player.scheduleBuffer(audioBuffer, atTime: nil, options: .Loops, completionHandler: nil)
        
        
        player.play()

    }

    @IBAction func changeEqHi(sender: NSSlider) {
        var filterParams = eq.bands[1] as AVAudioUnitEQFilterParameters
        filterParams.frequency = sender.floatValue
    }
    
    @IBAction func changeEqLo(sender: NSSlider) {
        var filterParams = eq.bands[0] as AVAudioUnitEQFilterParameters
        filterParams.frequency = sender.floatValue
        NSLog("%f", filterParams.frequency)
    }

}

