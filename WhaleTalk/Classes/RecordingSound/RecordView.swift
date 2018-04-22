//
//  ViewController.swift
//  WhaleTalk
//
//  Created by James VanBeverhoudt on 4/19/18.
//  Copyright © 2018 Bevtech. All rights reserved.
//

import UIKit
import AVFoundation
import ReactiveSwift
import ReactiveCocoa

final class RecordView: UIViewController {

    // MARK: Propertie

    private let vm = RecordingViewModel()

    private let recordButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Tap to record", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        return button
    }()

    private let alertTextLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()

    // MARK: View life-cycle

    override func loadView() {
        super.loadView()

        view.backgroundColor = .gray
        view.layoutMargins = UIEdgeInsets(top: 40, left: 20, bottom: 40, right: 20)

        let subviews: [UIView] = [
            recordButton,
            alertTextLabel,
        ]
        subviews.forEach { view.addSubview($0) }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        vm.requestMicrophonePermissions()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        bindViewModel()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let layoutFrame = UIEdgeInsetsInsetRect(view.bounds, view.layoutMargins)

        recordButton.frame = layoutFrame
        recordButton.frame.size.height = 44

        alertTextLabel.frame = layoutFrame
        alertTextLabel.frame.origin.y = recordButton.frame.maxY + 20
//        alertTextLabel.frame.size.height = alertTextLabel
    }

    // MARK: Binding

    private func bindViewModel() {
        alertTextLabel.reactive.isHidden <~ vm.isAlertLabelHidden
        alertTextLabel.reactive.textColor <~ vm.alertLabelTextRGB
            .map { UIColor(red: $0.0, green: $0.1, blue: $0.2, alpha: 1) }

    }
}
