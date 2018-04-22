//
//  RecordingViewModel.swift
//  WhaleTalk
//
//  Created by James VanBeverhoudt on 4/22/18.
//  Copyright © 2018 Bevtech. All rights reserved.
//

import Foundation
import AVFoundation
import ReactiveSwift
import Result

final class RecordingViewModel {
    let isRecordingPermissionsAllowed: Signal<Bool, NoError>
    let _isRecordingPermissionsAllowed: Signal<Bool, NoError>.Observer

    let isAlertLabelHidden = MutableProperty<Bool>(true)
    let alertLabelTextRGB = MutableProperty<(CGFloat, CGFloat, CGFloat)>((139/255, 0, 0))

    private let recordingSession = AVAudioSession.sharedInstance()
    private var whistleRecorder: AVAudioRecorder?

    init() {
        (isRecordingPermissionsAllowed, _isRecordingPermissionsAllowed) = Signal.pipe()
    }

    func requestMicrophonePermissions() {
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission { [unowned self] allowed in
                self._isRecordingPermissionsAllowed.send(value: allowed)
                self._isRecordingPermissionsAllowed.sendCompleted()
            }
        } catch {
            _isRecordingPermissionsAllowed.send(value: false)
            _isRecordingPermissionsAllowed.sendCompleted()
        }
    }
}
