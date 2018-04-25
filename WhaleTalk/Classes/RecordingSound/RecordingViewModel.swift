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
import ReactiveCocoa
import Result
import Whalify

final class RecordingViewModel: NSObject {

    let isAlertLabelHidden: Property<Bool>
    let alertLabelTextRGB: Property<(CGFloat, CGFloat, CGFloat)>
    let alertText: Property<String?>
    let recordButtonTextRGB: Property<(CGFloat, CGFloat, CGFloat)>
    let recordButtonText: Property<String>

    private let isRecordingPermissionsAllowed: Signal<Bool, NoError>
    private let _isRecordingPermissionsAllowed: Signal<Bool, NoError>.Observer

    private let isRecording = MutableProperty<Bool>(false)

    private let recordingSession = AVAudioSession.sharedInstance()
    private var recorder: AVAudioRecorder?

    private let audioURL = RecordingViewModel.getToTranslateWhaleURL()
    private let audioSettings = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 12000,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]

    override init() {
        (isRecordingPermissionsAllowed, _isRecordingPermissionsAllowed) = Signal.pipe()
        isAlertLabelHidden = Property(initial: true, then: isRecordingPermissionsAllowed)

        let green: (CGFloat, CGFloat, CGFloat) = (76/255.0, 187/255.0, 23/255.0)
        let red: (CGFloat, CGFloat, CGFloat) = (139/255, 0, 0)
        let white: (CGFloat, CGFloat, CGFloat) = (1, 1, 1)

        let colorSignal = isRecordingPermissionsAllowed.map { $0 ? red : green }
        alertLabelTextRGB = Property(initial: red, then: colorSignal)

        let alertTextSignal = isRecordingPermissionsAllowed.map { $0 ? nil : "Recording failed: please ensure the app has access to your microphone." }
        alertText = Property(initial: nil, then: alertTextSignal)

        let recordColorSignal = isRecording.signal.map { $0 ? red : white }
        recordButtonTextRGB = Property(initial: white, then: recordColorSignal)

        let recordButtonTextSignal = isRecording.signal.map { $0 ? "Tap to stop" : "Tap to record" }
        recordButtonText = Property(initial: "Tap to record", then: recordButtonTextSignal)

        super.init()

        isRecording.signal.observeValues { [unowned self] isRecording in
            if isRecording {
                self.startRecord()
            } else {
                self.stopRecord()
            }
        }
    }

    private func startRecord() {
        do {
            recorder = try AVAudioRecorder(url: audioURL, settings: audioSettings)
            recorder?.delegate = self
            recorder?.record()
        } catch {
            assertionFailure("failed recording")
        }
    }

    private func stopRecord() {
        recorder?.stop()
        recorder = nil
    }

    class func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    class func getToTranslateWhaleURL() -> URL {
        return getDocumentsDirectory().appendingPathComponent("toTranslateWhale.m4a")
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

    func didTapRecord() {
        isRecording.value = !isRecording.value
    }
}

extension RecordingViewModel: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        Whalify.changePitchOf(sound: RecordingViewModel.getToTranslateWhaleURL())
    }
}
