import UIKit

final class RecordingSessionViewController: UIViewController {
    private let model: RecordingSessionModel
    private var isDismissalInProgress = false

    private let timerLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedDigitSystemFont(ofSize: 42, weight: .medium)
        label.textAlignment = .center
        label.accessibilityIdentifier = "RecordingSessionTimer"
        return label
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .interactive
        tableView.accessibilityIdentifier = "RecordingSessionTranscript"
        return tableView
    }()

    private lazy var pauseButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.cornerStyle = .capsule
        configuration.imagePadding = 8
        let button = UIButton(configuration: configuration)
        button.addTarget(self, action: #selector(togglePause), for: .touchUpInside)
        button.accessibilityIdentifier = "RecordingSessionPauseButton"
        return button
    }()

    private lazy var stopButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.cornerStyle = .capsule
        configuration.baseBackgroundColor = .systemRed
        configuration.baseForegroundColor = .white
        configuration.image = UIImage(systemName: "stop.fill")
        configuration.imagePadding = 8
        configuration.title = "Stop"
        let button = UIButton(configuration: configuration)
        button.addTarget(self, action: #selector(stopRecording), for: .touchUpInside)
        button.accessibilityIdentifier = "RecordingSessionStopButton"
        return button
    }()

    init(model: RecordingSessionModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = model.language.name
        view.backgroundColor = .systemBackground
        tableView.dataSource = self
        tableView.register(
            TranscriptTableViewCell.self,
            forCellReuseIdentifier: TranscriptTableViewCell.reuseIdentifier
        )
        configureLayout()
        bindModel()
        render()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentationController?.delegate = self
        model.start()
    }

    private func configureLayout() {
        let headingLabel = UILabel()
        headingLabel.text = "\(model.language.name) Transcription"
        headingLabel.font = .preferredFont(forTextStyle: .title2)
        headingLabel.textAlignment = .center

        let controls = UIStackView(arrangedSubviews: [pauseButton, stopButton])
        controls.axis = .horizontal
        controls.spacing = 16
        controls.distribution = .fillEqually

        let header = UIStackView(arrangedSubviews: [headingLabel, timerLabel, statusLabel])
        header.axis = .vertical
        header.spacing = 6

        [header, tableView, controls].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: guide.topAnchor, constant: 24),
            header.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 20),
            header.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -20),

            tableView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            controls.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 12),
            controls.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 20),
            controls.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -20),
            controls.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -16),
            controls.heightAnchor.constraint(equalToConstant: 54)
        ])
    }

    private func bindModel() {
        model.onChange = { [weak self] in
            self?.render()
        }
        model.onError = { [weak self] error in
            self?.presentError(error)
        }
    }

    private func render() {
        timerLabel.text = model.formattedTimestamp(model.elapsedTime)
        switch model.status {
        case .idle:
            statusLabel.text = "Starting…"
            pauseButton.isEnabled = false
            setPauseButton(title: "Pause", image: "pause.fill")
        case .recording:
            statusLabel.text = "Recording"
            pauseButton.isEnabled = true
            setPauseButton(title: "Pause", image: "pause.fill")
        case .paused:
            statusLabel.text = "Paused"
            pauseButton.isEnabled = true
            setPauseButton(title: "Resume", image: "mic.fill")
        case .stopped:
            statusLabel.text = "Stopped"
            pauseButton.isEnabled = false
            stopButton.isEnabled = false
        }

        tableView.reloadData()
        let count = tableView.numberOfRows(inSection: 0)
        if !model.rows.isEmpty || !model.liveText.isEmpty {
            tableView.scrollToRow(
                at: IndexPath(row: count - 1, section: 0),
                at: .bottom,
                animated: false
            )
        }
    }

    private func setPauseButton(title: String, image: String) {
        pauseButton.configuration?.title = title
        pauseButton.configuration?.image = UIImage(systemName: image)
        pauseButton.accessibilityLabel = title
    }

    @objc private func togglePause() {
        switch model.status {
        case .recording:
            model.pause()
        case .paused:
            model.resume()
        case .idle, .stopped:
            break
        }
    }

    @objc private func stopRecording() {
        model.stop()
    }

    private func presentError(_ error: Error) {
        let alert = UIAlertController(
            title: "Transcription unavailable",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Close", style: .default) { [weak self] _ in
            guard let self else { return }
            isDismissalInProgress = true
            dismiss(animated: true)
        })
        present(alert, animated: true)
    }
}

extension RecordingSessionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        model.rows.count + (model.liveText.isEmpty ? 0 : 1)
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TranscriptTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? TranscriptTableViewCell else {
            return UITableViewCell()
        }

        if indexPath.row < model.rows.count {
            let row = model.rows[indexPath.row]
            cell.configure(
                timestamp: model.formattedTimestamp(row.timestamp),
                text: row.text,
                isLive: false
            )
        } else {
            cell.configure(
                timestamp: model.formattedTimestamp(model.liveTimestamp ?? model.elapsedTime),
                text: model.liveText,
                isLive: true
            )
        }
        return cell
    }
}

extension RecordingSessionViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        isDismissalInProgress = true
        model.stop()
    }
}

private final class TranscriptTableViewCell: UITableViewCell {
    private let timestampLabel = UILabel()
    private let transcriptLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        timestampLabel.font = .monospacedDigitSystemFont(ofSize: 13, weight: .medium)
        timestampLabel.textColor = .secondaryLabel
        transcriptLabel.font = .preferredFont(forTextStyle: .body)
        transcriptLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [timestampLabel, transcriptLabel])
        stack.axis = .horizontal
        stack.alignment = .firstBaseline
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            timestampLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(timestamp: String, text: String, isLive: Bool) {
        timestampLabel.text = timestamp
        transcriptLabel.text = text
        transcriptLabel.textColor = isLive ? .secondaryLabel : .label
        accessibilityLabel = "\(timestamp), \(text)"
    }
}
