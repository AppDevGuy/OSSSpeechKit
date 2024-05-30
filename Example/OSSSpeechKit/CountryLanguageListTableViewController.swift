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
import OSSSpeechKit

class CountryLanguageListTableViewController: UITableViewController {
    
    // MARK: - Variables
    
    private let speechKit = OSSSpeech.shared

    private lazy var microphoneButton: UIBarButtonItem = {
        var micImage: UIImage?
        micImage = UIImage(systemName: "mic.fill")?.withRenderingMode(.alwaysTemplate)
        let button = UIBarButtonItem(image: micImage, style: .plain, target: self, action: #selector(recordVoice))
        button.tintColor = .label
        button.accessibilityIdentifier = "OSSSpeechKitMicButton"
        return button
    }()
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Languages"
        tableView.accessibilityIdentifier = "OSSSpeechKitLanguageTableView"
        speechKit.delegate = self
        navigationItem.rightBarButtonItem = microphoneButton
        tableView.register(CountryLanguageTableViewCell.self,
                           forCellReuseIdentifier: CountryLanguageTableViewCell.reuseIdentifier)
    }
    
    // MARK: - Voice Recording
    
    @objc func recordVoice() {
        shoudlStartRecordingVoice(microphoneButton.tintColor != .red)
    }

    private func shoudlStartRecordingVoice(_ shouldRecord: Bool) {
        updateMicButtonColor(forState: shouldRecord)
        if !shouldRecord {
            speechKit.endVoiceRecording()
            return
        }
        speechKit.recordVoice()
    }

    func updateMicButtonColor(forState isRecording: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.microphoneButton.tintColor = isRecording ? .red : .label
        }
    }
}

extension CountryLanguageListTableViewController {

    // MARK: - Table View Data Source and Delegate

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return OSSVoiceEnum.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CountryLanguageTableViewCell.reuseIdentifier,
                                                       for: indexPath) as? CountryLanguageTableViewCell else {
            return UITableViewCell(style: .subtitle, reuseIdentifier: UITableViewCell.reuseIdentifier)
        }
        cell.language = OSSVoiceEnum.allCases[indexPath.row]
        cell.isAccessibilityElement = true
        cell.accessibilityIdentifier = "OSSLanguageCell_\(indexPath.section)_\(indexPath.row)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // NOTE: Must set the voice before requesting speech. This can be set once.
        speechKit.voice = OSSVoice(quality: .enhanced, language: OSSVoiceEnum.allCases[indexPath.item])
        speechKit.utterance?.rate = 0.45
        // Test attributed string vs normal string
        if indexPath.item % 2 == 0 {
            speechKit.speakText(OSSVoiceEnum.allCases[indexPath.item].demoMessage)
        } else {
            let attributedString = NSAttributedString(string: OSSVoiceEnum.allCases[indexPath.item].demoMessage)
            speechKit.speakAttributedText(attributedText: attributedString)
        }
    }
}

extension CountryLanguageListTableViewController: OSSSpeechDelegate {
    func deleteVoiceFile(withFinish finish: Bool, withError error: Error?) {
        
    }
    
    func voiceFilePathTranscription(withText text: String) {
        
    }
    
    func didFinishListening(withAudioFileURL url: URL, withText text: String) {
        print("Translation completed: \(text). And user voice file path: \(url.absoluteString)")
    }
    
    func didCompleteTranslation(withText text: String) {
        print("Translation completed: \(text)")
    }
    
    func didFailToProcessRequest(withError error: Error?) {
        shoudlStartRecordingVoice(false)
        guard let err = error else {
            print("Error with the request but the error returned is nil")
            return
        }
        print("Error with the request: \(err)")
    }
    
    func authorizationToMicrophone(withAuthentication type: OSSSpeechKitAuthorizationStatus) {
        print("Authorization status has returned: \(type.message).")
    }
    
    func didFailToCommenceSpeechRecording() {
        print("Failed to record speech.")
        shoudlStartRecordingVoice(false)
    }
    
    func didFinishListening(withText text: String) {
        OperationQueue.main.addOperation { [weak self] in
            self?.updateMicButtonColor(forState: false)
            self?.speechKit.speakText(text)
        }
    }
}

extension UIView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
