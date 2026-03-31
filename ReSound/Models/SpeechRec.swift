//
//  SpeechRec.swift
//  ReSound
//
//  Created by Dương Anh Trần on 19/3/2026.
//  Copyright © 2026 Apple. All rights reserved.
//
import Speech
import AVFoundation

@Observable
class SpeechRec {
    var isRecording: Bool = false
    var speechContent: String = ""

    /// Speech recognition pipeline (I saw this on google - testing)
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine = AVAudioEngine()
    private let recogniser = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))

    /// Ask for authorisation
    func authoriseRequest() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                DispatchQueue.main.async {
                    continuation.resume(returning: status == .authorized)
                }
            }
        }
    }

    /// Recognise function:
    func startRec() throws {
        guard !isRecording else {
            return
        }

        /// For actual implementation (Can't test on sim)
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = true

        let inputNode = audioEngine.inputNode
        recognitionTask = recogniser?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            if let result {
                self?.speechContent = result.bestTranscription.formattedString
            }
            if error != nil || (result?.isFinal ?? false) {
                self?.stopRec()
            }
        }

        let format = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            recognitionRequest.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()
        isRecording = true
    }

    /// Stop recognise:
    func stopRec() {
        guard isRecording else {
            return
        }

        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
        isRecording = false
        speechContent = ""
    }
}
