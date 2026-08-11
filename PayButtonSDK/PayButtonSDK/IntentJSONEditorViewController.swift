//
//  IntentJSONEditorViewController.swift
//  PayButtonSDK
//
//  The mobile counterpart of the json editor the web demo shows under
//  "Config Object (Create Intent)". Lets you edit any field of the intent,
//  not only the ones the settings form happens to expose.
//

import UIKit

class IntentJSONEditorViewController: UIViewController {

    /// Called once the edited json has been parsed and applied
    var onSaved: (() -> Void)?

    private let textView: UITextView = {
        let t = UITextView()
        t.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        t.autocorrectionType = .no
        t.autocapitalizationType = .none
        t.smartQuotesType = .no
        t.smartDashesType = .no
        t.keyboardType = .asciiCapable
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()

    private let statusLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12)
        l.numberOfLines = 0
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private var bottomConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Intent JSON"
        view.backgroundColor = .systemBackground

        navigationItem.leftBarButtonItem = .init(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .save, target: self, action: #selector(saveTapped))

        view.addSubview(textView)
        view.addSubview(statusLabel)

        let bottom = textView.bottomAnchor.constraint(equalTo: statusLabel.topAnchor, constant: -8)
        bottomConstraint = bottom
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            bottom,
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            statusLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
        ])

        textView.text = prettyPrintedIntent()
        showStatus("Edit any field, then Save. Save also validates the json.", isError: false)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChanged(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHidden), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // MARK: - Content

    /// The intent exactly as it will be posted, pretty printed with the keys in a stable order
    private func prettyPrintedIntent() -> String {
        guard let data = try? PayButtonExample.intentRequestRequest.jsonData(),
              let object = try? JSONSerialization.jsonObject(with: data),
              let pretty = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]) else {
            return "{}"
        }
        return String(decoding: pretty, as: UTF8.self)
    }

    private func showStatus(_ message: String, isError: Bool) {
        statusLabel.text = message
        statusLabel.textColor = isError ? .systemRed : .secondaryLabel
    }

    // MARK: - Actions

    /// Works whether we were pushed onto the example's navigation stack or presented modally
    private func close(completion: (() -> Void)? = nil) {
        if let navigationController = navigationController, navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
            completion?()
        } else {
            dismiss(animated: true, completion: completion)
        }
    }

    @objc private func cancelTapped() {
        close()
    }

    @objc private func saveTapped() {
        let edited:String = textView.text ?? ""

        // First make sure it is json at all, the parser error points at the character that broke it
        guard let data = edited.data(using: .utf8) else {
            showStatus("Could not read the text as utf8", isError: true)
            return
        }
        do {
            _ = try JSONSerialization.jsonObject(with: data)
        } catch {
            showStatus("Invalid json: \(error.localizedDescription)", isError: true)
            return
        }

        // Then make sure the intent model understands it
        do {
            PayButtonExample.intentRequestRequest = try IntentRequest(data: data)
        } catch {
            showStatus("Json is valid but the intent model rejected it: \(error)", isError: true)
            return
        }

        close { [weak self] in
            self?.onSaved?()
        }
    }

    // MARK: - Keyboard

    @objc private func keyboardChanged(_ note: Notification) {
        guard let frame = (note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let overlap = max(0, view.bounds.maxY - view.convert(frame, from: nil).minY)
        bottomConstraint?.constant = -8 - overlap
        view.layoutIfNeeded()
    }

    @objc private func keyboardHidden() {
        bottomConstraint?.constant = -8
        view.layoutIfNeeded()
    }
}
