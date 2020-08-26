//  Copyright © 2018-2020 App Dev Guy. All rights reserved.
//
//  This code is distributed under the terms and conditions of the MIT license.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
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
    
    static func fft(data: UnsafeMutablePointer<Float>, setup: OpaquePointer) -> [Float] {
        let countValue = 1024
        //output setup
        var realIn = [Float](repeating: 0, count: countValue)
        var imagIn = [Float](repeating: 0, count: countValue)
        var realOut = [Float](repeating: 0, count: countValue)
        var imagOut = [Float](repeating: 0, count: countValue)
        //fill in real input part with audio samples
        for i in 0..<countValue {
            realIn[i] = data[i]
        }
        vDSP_DFT_Execute(setup, &realIn, &imagIn, &realOut, &imagOut)
        var normalizedMagnitudes: [Float] = []
        // our results are now inside realOut and imagOut
        // package it inside a complex vector representation used in the vDSP framework
        realOut.withUnsafeMutableBufferPointer { realBP in
            imagOut.withUnsafeMutableBufferPointer { imaginaryBP in
                let realPtr = UnsafeMutablePointer(mutating: realBP.baseAddress!)
                let imaginaryPtr = UnsafeMutablePointer(mutating: imaginaryBP.baseAddress!)
                var complex = DSPSplitComplex(realp: realPtr, imagp: imaginaryPtr)
                // setup magnitude output
                var magnitudes = [Float](repeating: 0, count: countValue / 2)
                // calculate magnitude results
                vDSP_zvabs(&complex, 1, &magnitudes, 1, UInt(countValue / 2))
                // normalize
                normalizedMagnitudes = [Float](repeating: 0.0, count: (countValue / 2))
                var scalingFactor = Float(25.0 / Double(countValue / 2))
                vDSP_vsmul(&magnitudes, 1, &scalingFactor, &normalizedMagnitudes, 1, UInt(countValue / 2))
            }
        }
        return normalizedMagnitudes
    }
    
    static func interpolate(current: Float, previous: Float) -> [Float] {
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
