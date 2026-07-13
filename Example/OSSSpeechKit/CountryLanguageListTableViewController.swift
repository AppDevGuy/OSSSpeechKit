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
    
    private let speechKit = OSSSpeechEngine()

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
        navigationItem.rightBarButtonItem = microphoneButton
        tableView.register(CountryLanguageTableViewCell.self,
                           forCellReuseIdentifier: CountryLanguageTableViewCell.reuseIdentifier)
    }
    
    // MARK: - Voice Recording
    
    @objc func recordVoice() {
        let selectedLanguage = tableView.indexPathForSelectedRow
            .map { OSSLanguage.catalog[$0.row] }
            ?? OSSLanguage.catalog.first(where: { $0.id == "english-us" })!
        let recordingController = RecordingSessionViewController(
            model: RecordingSessionModel(language: selectedLanguage)
        )
        recordingController.modalPresentationStyle = .pageSheet
        if let sheet = recordingController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.selectedDetentIdentifier = .large
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        present(recordingController, animated: true)
    }
}

extension CountryLanguageListTableViewController {

    // MARK: - Table View Data Source and Delegate

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return OSSLanguage.catalog.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CountryLanguageTableViewCell.reuseIdentifier,
                                                       for: indexPath) as? CountryLanguageTableViewCell else {
            return UITableViewCell(style: .subtitle, reuseIdentifier: UITableViewCell.reuseIdentifier)
        }
        cell.language = OSSLanguage.catalog[indexPath.row]
        cell.isAccessibilityElement = true
        cell.accessibilityIdentifier = "OSSLanguageCell_\(indexPath.section)_\(indexPath.row)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let language = OSSLanguage.catalog[indexPath.row]
        Task {
            do {
                try await speak("Hello from \(language.name)", language: language)
            } catch {
                presentError(error)
            }
        }
    }

    private func speak(_ text: String, language: OSSLanguage) async throws {
        try await speechKit.speak(
            text,
            voice: OSSVoiceConfiguration(language: language),
            configuration: .init(rate: 0.45)
        )
    }

    private func presentError(_ error: Error) {
        var message = error.localizedDescription
        if case OSSSpeechError.voiceUnavailable = error {
            message += "\n\nOn the simulator, open Settings > Accessibility > Spoken Content > Voices and download a voice for the selected language."
        }
        let alert = UIAlertController(
            title: "Speech unavailable",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension UIView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
