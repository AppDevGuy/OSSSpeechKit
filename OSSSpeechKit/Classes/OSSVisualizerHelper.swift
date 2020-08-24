//
//  OSSVisualizerHelper.swift
//  OSSSpeechKit
//
//  Created by Sean Smith on 24/8/20.
//

import Foundation
import Accelerate

class OSSVisualizerHelper {
    
    static func rms(data: UnsafeMutablePointer<Float>, frameLength: UInt) -> Float {
        var val : Float = 0
        vDSP_measqv(data, 1, &val, frameLength)
        var db = 10 * log10f(val)
        // Inverse dB to +ve range where 0(silent) -> 160(loudest)
        db = 160 + db;
        // Only take into account range from 120->160, so FSR = 40
        db = db - 120
        let dividor = Float(40 / 0.3)
        var adjustedVal = 0.3 + db / dividor
        //cutoff
        if (adjustedVal < 0.3) {
            adjustedVal = 0.3
        } else if (adjustedVal > 0.6) {
            adjustedVal = 0.6
        }
        
        return adjustedVal
    }
    
    static func fft(data: UnsafeMutablePointer<Float>, setup: OpaquePointer) -> [Float]{
        let countValue = 1024
        //output setup
        var realIn = [Float](repeating: 0, count: countValue)
        var imagIn = [Float](repeating: 0, count: countValue)
        var realOut = [Float](repeating: 0, count: countValue)
        var imagOut = [Float](repeating: 0, count: countValue)
        //fill in real input part with audio samples
        for i in 0...countValue {
            realIn[i] = data[i]
        }
        vDSP_DFT_Execute(setup, &realIn, &imagIn, &realOut, &imagOut)
        // our results are now inside realOut and imagOut
        // package it inside a complex vector representation used in the vDSP framework
        var complex = DSPSplitComplex(realp: &realOut, imagp: &imagOut)
        // setup magnitude output
        var magnitudes = [Float](repeating: 0, count: countValue / 2)
        // calculate magnitude results
        vDSP_zvabs(&complex, 1, &magnitudes, 1, UInt(countValue / 2))
        // normalize
        var normalizedMagnitudes = [Float](repeating: 0.0, count: (countValue / 2))
        var scalingFactor = Float(25.0 / Double(countValue / 2))
        vDSP_vsmul(&magnitudes, 1, &scalingFactor, &normalizedMagnitudes, 1, UInt(countValue / 2))
        return normalizedMagnitudes
    }
    
    static func interpolate(current: Float, previous: Float) -> [Float]{
        var vals = [Float](repeating: 0, count: 11)
        vals[10] = current
        vals[5] = (current + previous) / 2
        vals[2] = (vals[5] + previous) / 2
        vals[1] = (vals[2] + previous) / 2
        vals[8] = (vals[5] + current) / 2
        vals[9] = (vals[10] + current) / 2
        vals[7] = (vals[5] + vals[9]) / 2
        vals[6] = (vals[5] + vals[7]) / 2
        vals[3] = (vals[1] + vals[5]) / 2
        vals[4] = (vals[3] + vals[5]) / 2
        vals[0] = (previous + vals[1]) / 2
        return vals
    }
}
