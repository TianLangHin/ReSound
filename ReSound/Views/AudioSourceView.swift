//
//  AudioSourceView.swift
//  ReSound
//
//  Created by Tian Lang Hin on 17/3/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

import SwiftUI
import RealityKit

/// This View corresponds exactly to one visual element that emits audio during the hearing test.
/// It can be adjusted to be playing audio or not,
/// and needs information about the hearing test it is playing from.
struct AudioSourceView: View {
    let audioSource: AudioSource
    let hearingTest: HearingTest

    @Binding var questionNumber: Int
    @Binding var isPlayingAudio: Bool

    /// Check if the audio already loaded (Benchmark purpose)
    @State private var isAudioLoaded = false

    // The main entity displaying the audio source.
    let entity = Entity()
    // The visual indicator if required.
    @State var indicatorEntity: Entity

    let defaultModel = ModelEntity(
        mesh: MeshResource.generateBox(size: [0.3, 0.3, 0.4]),
        materials: [UnlitMaterial(color: .systemBlue)])

    var body: some View {
        RealityView { content in
            // First, the entity is loaded at the predefined distance from the user.
            content.add(entity)
            entity.transform = Transform(translation: audioSource.location)

            // We construct the visual representation here.
            switch audioSource.visualResourceLink {
            case .presetBox:
                // Making a simple box entity of colour blue (i.e., use the default).
                entity.addChild(defaultModel)
            case let .asset(assetName):
                // `assetName` should be the name of a USDZ file.
                if let entityAsset = try? await Entity(named: assetName) {
                    entityAsset.scale *= 0.3
                    entity.addChild(entityAsset)
                } else {
                    entity.addChild(defaultModel)
                }
            }

            // Next, we determine whether we need to add the extra visual indicator or not.
            let currentQuestion = hearingTest.questions[questionNumber]
            let isFocused = currentQuestion.focus == audioSource.id

            // Attach the child `indicatorEntity` to be slightly above the object to be focused.
            self.indicatorEntity.position = [0, 1.0, 0]
            if isFocused {
                entity.addChild(self.indicatorEntity)
            }
        } update: { content in
            /// All updates occur here.

            /// Step 1: Determine whether we need to display the visual indicator or not.
            let newQuestion = hearingTest.questions[questionNumber]
            let isFocused = newQuestion.focus == audioSource.id
            if isFocused {
                content.entities[0].addChild(self.indicatorEntity)
            } else {
                content.entities[0].removeChild(self.indicatorEntity)
            }

            /// Step 2: Determing whether we need to play the audio.
            /// Added logic here to ensure the mechanism preventing double sound works correctly.
            if isPlayingAudio && !isAudioLoaded {

                // Avoid double sound (Benchmark purpose)
                Task { @MainActor in
                    isAudioLoaded = true
                }

                // Find the audio resource to load.
                let audioLink = if newQuestion.focus == audioSource.id {
                    newQuestion.chosenQuestion.audioResourceLink
                } else {
                    switch audioSource.type {
                    case let .conversation(audioName):
                        audioName ?? Presets.conversationAudioClips[0]
                    case let .ambient(audioName):
                        audioName ?? Presets.ambientAudioClips[0]
                    }
                }

                // Load the audio clip.
                guard let audio = try? AudioFileResource.load(
                    named: audioLink,
                    configuration: AudioFileResource.Configuration(shouldLoop: true)) else {
                    // Handle the error if the audio file fails to load. Stub for now.
                    print("Failed to load audio file.")
                    return
                }
                // Set the spatial audio settings of the entity, attach it to the entity, and play the audio.
                content.entities[0].spatialAudio = SpatialAudioComponent(directivity: .beam(focus: 0.2))
                let audioController = content.entities[0].playAudio(audio)

                // Set the clip to stop playing after the question's duration times out.
                Task { @MainActor in
                    try? await Task.sleep(for: newQuestion.duration)
                    audioController.stop()
                    // This feeds the status of stopping audio back to the outer scenes.
                    isPlayingAudio = false
                    isAudioLoaded = false
                }
            }
        }
    }

}
