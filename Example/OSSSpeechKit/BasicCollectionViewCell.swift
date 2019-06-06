//
//  BasicCollectionViewCell.swift
//  OSSSpeechKit_Example
//
//  Created by Sean Smith on 6/6/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

class BasicCollectionViewCell: UICollectionViewCell {
    
    public let titleLabel = UILabel()
    public let subtitleLabel = UILabel()
    
    // MARK: - Variables
    var hasSetConstraints: Bool = false
    
    // MARK: - View Elements
    
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        titleLabel.font = UIFont.systemFont(ofSize: 25.0, weight: .bold)
        titleLabel.textAlignment = .center
        subtitleLabel.font = UIFont.systemFont(ofSize: 18.0, weight: .bold)
        subtitleLabel.textAlignment = .center
        titleLabel.textColor = .black
        subtitleLabel.textColor = .black
        self.addSubview(titleLabel)
        self.addSubview(subtitleLabel)
    }
    
    // MARK: - Layouts
    override func updateConstraints() {
        super.updateConstraints()
        if !self.hasSetConstraints {
            self.hasSetConstraints = true
            let inset: CGFloat = 8.0
            self.titleLabel.autoPinEdge(toSuperviewEdge: .top, withInset: inset)
            self.titleLabel.autoPinEdge(toSuperviewEdge: .left, withInset: inset * 2)
            self.titleLabel.autoPinEdge(toSuperviewEdge: .right, withInset: inset * 2)
            self.subtitleLabel.autoPinEdge(toSuperviewEdge: .left, withInset: inset * 2)
            self.subtitleLabel.autoPinEdge(toSuperviewEdge: .right, withInset: inset * 2)
            self.subtitleLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: inset * 2)
        }
    }
    
    // MARK: Public Methods
    
    // MARK: Private Methods
    
}
