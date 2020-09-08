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

import UIKit

/// Ensure that the display of the visualizer with simple enum.
///
/// The values for the barWidth are divisable of 360 which is necessary to ensure complete coverage of the circular view.
/// The bar width is optimised for the number of bars.
public enum OSSVisualizerCircularViewBarType {
    /// Use this value to provide your own. If this value is called and no values provided, medium values will be used.
    case custom
    /// 30 bars at a width of 4.0
    case low
    /// 45 bars at a width of 3.0
    case medium
    /// 60 bars at a width of 2.0
    case high
    /// 90 bars at a width of 1.3
    case extraHigh
    /// 180 bars at a width of 0.6
    case extreme

    /// Returns a bar count for the enum.
    public var barCount: Int {
        switch self {
            case .low:
                return 30
            case .medium:
                return 45
            case .high:
                return 60
            case .extraHigh:
                return 90
            case .extreme:
                return 180
            default:
                return 30
        }
    }
    
    /// Returns a bar width for the enum.
    public var barWidth: CGFloat {
        switch self {
            case .low:
                return 4
            case .medium:
                return 3
            case .high:
                return 2
            case .extraHigh:
                return 1.3
            case .extreme:
                return 0.6
            default:
                return 1
        }
    }
}

public class OSSVisualizerCircularView: UIView {
    /// Visualizer color
    ///
    /// Default is system blue.
    public var visualizerColor: UIColor = .systemBlue {
        didSet {
            let animateTime = isVisualizerActive ? animateDuration : 0.0
            UIView.animate(withDuration: animateTime, delay: 0, options: .beginFromCurrentState, animations: {
                self.imageView.tintColor = self.visualizerColor
            })
        }
    }
    /// Visualizer Inner color
    ///
    /// Default is clear.
    public var visualizerInnerColor: UIColor = .clear
    /// The number of bars for the view to display.
    ///
    /// Default is OSSVisualizerCircularViewBarType.medium.barCount
    public var barsViewsCount: Int = OSSVisualizerCircularViewBarType.medium.barCount
    /// The the width of the bar..
    ///
    /// Default is OSSVisualizerCircularViewBarType.medium.barWidth
    public var barWidth: CGFloat = OSSVisualizerCircularViewBarType.medium.barWidth
    /// Setting the bar type is convenient way of ensuring that the display is correct.
    ///
    /// Because the view is circular, the bar view count must be a divisable value of 360.
    ///
    /// Default is .custom - will use the publicly accessible values of barViewsCount and barWidth.
    public var barType: OSSVisualizerCircularViewBarType = .custom
    /// Change the image for the image view.
    public var image: UIImage? = UIImage(systemName: "mic.fill") {
        didSet {
            imageView.image = image
        }
    }
    /// Check if the view is active or not.
    public var isVisualizerActive = false
    private var imageView = UIImageView()
    private let animateDuration = 0.3
    private let radius: CGFloat = 60
    private var radians = [CGFloat]()
    private var barPoints = [CGPoint]()
    private var rectArray = [UIView]()
    private var waveFormArray = [Int]()
    private var initialBarHeight: CGFloat = 0.0
    private let mainLayer: CALayer = CALayer()
    // draw circle
    private var midViewX: CGFloat!
    private var midViewY: CGFloat!
    private var circlePath = UIBezierPath()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        addSubview(imageView)
        layer.addSublayer(mainLayer)
    }
    
    public override func layoutSubviews() {
        mainLayer.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        if barType != .custom {
            barWidth = barType.barWidth
            barsViewsCount = barType.barCount
        }
        drawVisualizer()
    }
    
    //-----------------------------------------------------------------
    // MARK: - Drawing Section
    //-----------------------------------------------------------------
    
    private func drawVisualizer() {
        midViewX = self.mainLayer.frame.midX
        midViewY = self.mainLayer.frame.midY
        // Draw Circle
        let arcCenter = CGPoint(x: midViewX, y: midViewY)
        let circlePath = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
        let circleShapeLayer = CAShapeLayer()
        circleShapeLayer.path = circlePath.cgPath
        circleShapeLayer.fillColor = visualizerInnerColor.cgColor
        circleShapeLayer.strokeColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        circleShapeLayer.lineWidth = 1.0
        mainLayer.addSublayer(circleShapeLayer)
        // This will ensure to only add the bars once:
        guard rectArray.count == 0 else { return } // If we already have bars, just return
        imageView.frame = CGRect(x: (frame.size.width / 4.0), y: (frame.size.height / 4.0), width: (frame.size.width / 2.0), height: (frame.size.height / 2.0))
        imageView.image = image
        imageView.tintColor = visualizerColor
        imageView.alpha = 0.3
        // Draw Bars
        rectArray = [UIView]()
        for i in 0..<barsViewsCount {
            let angle = ((360 / barsViewsCount) * i) - 90
            let point = calculatePoints(angle: angle, radius: radius)
            let radian = angle.degreesToRadians
            radians.append(radian)
            barPoints.append(point)
            let rectangle = UIView(frame: CGRect(x: barPoints[i].x, y: barPoints[i].y, width: barWidth, height: barWidth))
            initialBarHeight = barWidth
            rectangle.setAnchorPoint(anchorPoint: CGPoint.zero)
            let rotationAngle = (CGFloat(( 360 / barsViewsCount) * i)).degreesToRadians + 180.degreesToRadians
            rectangle.transform = CGAffineTransform(rotationAngle: rotationAngle)
            rectangle.backgroundColor = visualizerColor
            rectangle.layer.cornerRadius = CGFloat(rectangle.bounds.width / 2)
            rectangle.tag = i
            addSubview(rectangle)
            rectArray.append(rectangle)
            let values = [5, 10, 15, 10, 5, 1]
            waveFormArray = [Int]()
            var j: Int = 0
            for _ in 0..<barsViewsCount {
                waveFormArray.append(values[j])
                j += 1
                if j == values.count {
                    j = 0
                }
            }
        }
    }
    
    private func calculatePoints(angle: Int, radius: CGFloat) -> CGPoint {
        let barX = midViewX + cos((angle).degreesToRadians) * radius
        let barY = midViewY + sin((angle).degreesToRadians) * radius
        return CGPoint(x: barX, y: barY)
    }
    
    // MARK: - Public Methods
    
    public func animateAudioVisualizer(withChanelOneValue channelOneValue: Float, channelTwoValue: Float) {
        isVisualizerActive = true
        DispatchQueue.main.async {
            // Ensure that bras can exceed the view size
            self.clipsToBounds = false
            self.layer.masksToBounds = false
            UIView.animateKeyframes(withDuration: self.animateDuration, delay: 0, options: .beginFromCurrentState, animations: {
                for i in 0..<self.barsViewsCount {
                    let channelValue: Int = Int(arc4random_uniform(2))
                    let wavePeak: Int = Int(arc4random_uniform(UInt32(self.waveFormArray[i])))
                    let barViewUn: UIView = self.rectArray[i]
                    let barH = (self.frame.height / 2 ) - self.radius
                    let scaled0 = (CGFloat(channelOneValue) * barH) / 60
                    let scaled1 = (CGFloat(channelTwoValue) * barH) / 60
                    let calc0 = barH - scaled0
                    let calc1 = barH - scaled1
                    if channelValue == 0 {
                        barViewUn.bounds.size.height = calc0
                    } else {
                        barViewUn.bounds.size.height = calc1
                    }
                    if barViewUn.bounds.height < CGFloat(4) {
                        barViewUn.bounds.size.height = self.initialBarHeight + CGFloat(wavePeak)
                    } else if barViewUn.bounds.height > 50.0 {
                        // 50 seems to be a great height. Could make this dynamic
                        barViewUn.bounds.size.height = 50.0
                    }
                    barViewUn.backgroundColor = self.visualizerColor
                }
                self.imageView.alpha = 1.0
            }, completion: nil)
        }
    }
    
    public func endAnimatingAudioVisualizer() {
        isVisualizerActive = false
        DispatchQueue.main.async {
            UIView.animate(withDuration: self.animateDuration, delay: 0, options: .beginFromCurrentState, animations: {
                for i in 0..<self.barsViewsCount {
                    let barView = self.rectArray[i]
                    barView.bounds.size.height = self.initialBarHeight
                    barView.bounds.origin.y = 120 - barView.bounds.size.height
                }
                self.imageView.alpha = 0.3
            }, completion: nil)
        }
    }
}

// MARK: - Extensions

extension BinaryInteger {
    var degreesToRadians: CGFloat { return CGFloat(Int(self)) * .pi / 180 }
}

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

extension UIView {
    func setAnchorPoint(anchorPoint: CGPoint) {
        var newPoint = CGPoint(x: self.bounds.size.width * anchorPoint.x, y: self.bounds.size.height * anchorPoint.y)
        var oldPoint = CGPoint(x: self.bounds.size.width * self.layer.anchorPoint.x, y: self.bounds.size.height * self.layer.anchorPoint.y)
        newPoint = newPoint.applying(self.transform)
        oldPoint = oldPoint.applying(self.transform)
        var position : CGPoint = self.layer.position
        position.x -= oldPoint.x
        position.x += newPoint.x;
        position.y -= oldPoint.y;
        position.y += newPoint.y;
        self.layer.position = position;
        self.layer.anchorPoint = anchorPoint;
    }
}
