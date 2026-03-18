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

    // This internal state is used to control automatic stopping of the audio clip after a certain duration.
    @State var audioController: AudioPlaybackController? = nil

    var body: some View {
        RealityView { content in
            // First, the entity is loaded at the predefined distance from the user.
            content.add(entity)
            entity.transform = Transform(translation: audioSource.location)

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
            let newQuestion = hearingTest.questions[questionNumber]
            let isFocused = newQuestion.focus == audioSource.id
            if isFocused {
                content.entities[0].addChild(self.indicatorEntity)
            } else {
                content.entities[0].removeChild(self.indicatorEntity)
            }
        }
        .onChange(of: isPlayingAudio) { _, newValue in
            // The audio will begin to play when the `isPlayingAudio` value binding is set to true.
            if newValue {
                let currentQuestion = hearingTest.questions[questionNumber]
                playAudio(audioLink: currentQuestion.chosenQuestion.audioResourceLink)
            }
        }
    }

    /// This function handles the initiation of playing audio,
    /// providing the information of the resource link in the call.
    func playAudio(audioLink: String) {
        let currentQuestion = hearingTest.questions[questionNumber]
        let audioLink = if currentQuestion.focus == audioSource.id {
            currentQuestion.chosenQuestion.audioResourceLink
        } else {
            // For now, this just takes the first possible preset conversation/ambient clip.
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

        // If any previous audio source is running, stop it.
        self.audioController?.stop()

        // Set the spatial audio settings of the entity, attach it to the entity, and play the audio.
        entity.spatialAudio = SpatialAudioComponent(directivity: .beam(focus: 1.0))
        self.audioController = entity.playAudio(audio)

        // Set the clip to stop playing after the question's duration times out.
        Task {
            let currentQuestion = hearingTest.questions[questionNumber]
            try? await Task.sleep(for: currentQuestion.duration)
            self.audioController?.stop()
            // Loading the question view after this will be the next task.
        }
    }
}
