//
//  ViewController.swift
//  OSSSpeechKit
//
//  Created by appdevguy on 06/06/2019.
//  Copyright (c) 2019 appdevguy. All rights reserved.
//

import UIKit
import PureLayout
import OSSSpeechKit

class ViewController: UIViewController {
    
    // MARK: - Variables
    
    private var hasSetConstraints: Bool = false
    private let speechKit = OSSSpeech.shared
    
    private lazy var microphoneButton: UIBarButtonItem = {
        let image = UIImage(named: "oss-microphone-icon")?.withRenderingMode(.alwaysTemplate)
        let button = UIBarButtonItem(image: image, style:.plain, target: self, action: #selector(recordVoice))
        button.tintColor = .black
        return button
    }()
    
    // MARK: - View Elements
    
    lazy var collectionView : UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = UIColor(white: 1.0, alpha: 0.0)
        // Register cell classes
        cv.register(BasicCollectionViewCell.self, forCellWithReuseIdentifier: BasicCollectionViewCell.reuseIdentifier)
        return cv
    }()

    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.addSubview(collectionView)
        self.view.backgroundColor = .lightGray
        self.title = "Languages"
        speechKit.delegate = self
        self.navigationItem.rightBarButtonItem = microphoneButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateViewConstraints()
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        if !hasSetConstraints {
            hasSetConstraints = true
            collectionView.autoPinEdgesToSuperviewSafeArea()
        }
    }
    
    // MARK: - Voice Recording
    
    @objc func recordVoice() {
        if self.microphoneButton.tintColor == .red {
            speechKit.endVoiceRecording()
            return
        }
        self.microphoneButton.tintColor = .red
        speechKit.recordVoice()
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = OSSVoiceEnum.allCases.count
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BasicCollectionViewCell.reuseIdentifier, for: indexPath) as! BasicCollectionViewCell
        cell.backgroundColor = .white
        cell.titleLabel.text = OSSVoiceEnum.allCases[indexPath.item].title
        cell.subtitleLabel.text = OSSVoiceEnum.allCases[indexPath.item].rawValue
        cell.imageView.image = OSSVoiceEnum.allCases[indexPath.item].flag
        cell.imageView.contentMode = .scaleAspectFit
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // NOTE: Must set the voice before requesting speech. This can be set once.
        speechKit.voice = OSSVoice(quality: .enhanced, language: OSSVoiceEnum.allCases[indexPath.item])
        speechKit.utterance?.rate = 0.45
        // Test attributed string vs normal string
        if indexPath.item % 2 == 0 {
            self.speechKit.speakText(OSSVoiceEnum.allCases[indexPath.item].demoMessage)
        } else {
            let attributedString = NSAttributedString(string: OSSVoiceEnum.allCases[indexPath.item].demoMessage)
            self.speechKit.speakAttributedText(attributedText: attributedString)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 80.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.setNeedsUpdateConstraints()
    }
    
    //Use for interspacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
}

extension ViewController: OSSSpeechDelegate {
    
    func didCompleteTranslation(withText text: String) {
        print("Translation completed: \(text)")
    }
    
    func didFailToProcessRequest(withError error: Error?) {
        guard let err = error else {
            print("Error with the request but the error returned is nil")
            return
        }
        print("Error with the request: \(err)")
    }
    
    func authorizationToMicrophone(withAuthentication type: OSSSpeechAuthorizationStatus) {
        print("Authorization status has returned: \(type.message).")
    }
    
    func didFailToCommenceSpeechRecording() {
        print("Failed to record speech.")
    }
    
    func didFinishListening(withText text: String) {
        OperationQueue.main.addOperation {
            self.microphoneButton.tintColor = .black
            self.speechKit.speakText(text)
        }
    }
}

extension UIView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
