//
//  OSSVisualizerView.swift
//  OSSSpeechKit
//
//  Created by Sean Smith on 24/8/20.
//

import UIKit

public class OSSVisualizerView: UIView {
    
    /// The number of bars for the view to display.
    ///
    /// Default is 10
    public var barsViewsCount: Int = 10
    /// Visualizer color
    ///
    /// Default is system blue.
    public var visualizerColor: UIColor = .systemBlue
    private var rectViewArray: [UIView] = []
    private var waveFormArray: [Int] = []
    private var hasSetLayout = false
    private var animateDuration = 0.15
    private var initialBarHeight: CGFloat = 0.0
    
    // MARK: - Lifecycle
    
    init() {
        super.init(frame: .zero)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func commonInit() {
        backgroundColor = .clear
    }
    
    // MARK: - Layout
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if !hasSetLayout && frame.size != .zero {
            hasSetLayout = true
            addEqualizerBars()
        }
    }
    
    // MARK: - Private Methods
    
    private func addEqualizerBars() {
        waveFormArray.removeAll()
        rectViewArray.removeAll()
        let barCount = CGFloat(barsViewsCount)
        let padding: CGFloat = (frame.size.width / barCount) / 3
        let rectHeight: CGFloat = frame.size.height - padding
        let rectWidth: CGFloat = (frame.size.width - padding * (barCount + 1)) / barCount
        for i in 0...barsViewsCount {
            let barView = UIView()
            let rect = CGRect(x: padding + (padding + rectWidth) * CGFloat(i), y: padding + (rectHeight - rectWidth), width: rectWidth, height: rectHeight)
            barView.frame = rect
            initialBarHeight = rect.height
            barView.backgroundColor = visualizerColor
            barView.layer.cornerRadius = rectWidth / 2
            addSubview(barView)
            rectViewArray.append(barView)
        }
        let waveFormVals = [5, 10, 15, 10, 5, 1]
        var j = 0
        for _ in 0...barsViewsCount {
            waveFormArray.append(waveFormVals[j])
            j += 1
            if j == waveFormVals.count {
                j = 0
            }
        }
    }
    
    // MARK: - Public Methods
    
    public func animateAudioVisualizer(withChanelOneValue channelOneValue: Float, channelTwoValue: Float) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: self.animateDuration, delay: 0.0, options: .beginFromCurrentState) {
                for i in 0...self.barsViewsCount {
                    let channelValue = arc4random_uniform(2)
                    let wavePeak = arc4random_uniform(UInt32(self.waveFormArray[i]))
                    let barView = self.rectViewArray[i]
                    barView.alpha = 1.0
                    var barFrame = barView.frame
                    let selectedLevel = channelValue == 0 ? channelOneValue : channelTwoValue
                    var newHeight = self.frame.size.height - CGFloat(1.0 / (selectedLevel * Float(self.barsViewsCount))) + CGFloat(wavePeak)
                    if newHeight < 4 || newHeight > self.frame.size.height {
                        newHeight = self.initialBarHeight + CGFloat(wavePeak)
                    }
                    barFrame.size.height = newHeight
                    barView.frame = barFrame
                }
            } completion: { (complete) in }
        }
    }
    
    public func endAnimatingAudioVisualizer() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: self.animateDuration, delay: 0.0, options: .beginFromCurrentState) {
                for i in 0...self.barsViewsCount {
                    let barView = self.rectViewArray[i]
                    barView.alpha = 0.5
                    var barFrame = barView.frame
                    barFrame.size.height = self.initialBarHeight
                    barView.frame = barFrame
                }
            } completion: { (complete) in }
        }
    }
    
}
