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

    // The main entity displaying the audio source.
    let entity = Entity()
    // The visual indicator if required.
    @State var indicatorEntity: Entity

    var body: some View {
        RealityView { content in
            // First, the entity is loaded at the predefined distance from the user.
            content.add(entity)
            entity.transform = Transform(translation: audioSource.location)
            entity.components.set(BillboardComponent())

            // We construct the visual representation here.
            switch audioSource.visualResourceLink {
            case .presetBox:
                // Making a simple box entity of colour blue.
                let mesh = MeshResource.generateBox(size: [0.3, 0.3, 0.3])
                let material = UnlitMaterial(color: .systemBlue)
                let boxEntity = ModelEntity(mesh: mesh, materials: [material])
                entity.addChild(boxEntity)
            case .asset:
                // Just a stub function for now. This should load a model from the Assets.
                entity.addChild(AxisVisualizer.make())
            }

            // Next, we determine whether we need to add the extra visual indicator or not.
            let currentQuestion = hearingTest.questions[questionNumber]
            let isFocused = currentQuestion.focus == audioSource.id

            // Attach the child `indicatorEntity` to be slightly above the object to be focused.
            self.indicatorEntity.position = [0, 0.3, 0]
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
            if isPlayingAudio {
                // Find the audio resource to load.
                let audioLink = if newQuestion.focus == audioSource.id {
                    newQuestion.chosenQuestion.audioResourceLink
                } else {
                    switch audioSource.type {
                    case .conversation:
                        Presets.conversationAudioClips[0]
                    case .ambient:
                        Presets.ambientAudioClips[0]
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
                Task {
                    try? await Task.sleep(for: newQuestion.duration)
                    audioController.stop()
                    // This feeds the status of stopping audio back to the outer scenes.
                    isPlayingAudio = false
                }
            }
        }
    }
}
