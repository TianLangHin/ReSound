//
//  AudioSourceView.swift
//  ReSound
//
//  Created by Tian Lang Hin on 17/3/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

import AVFoundation
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

    @Binding var heightOffset: Float

    let defaultModel = ModelEntity(
        mesh: MeshResource.generateBox(size: [0.3, 0.3, 0.4]),
        materials: [UnlitMaterial(color: .systemBlue)])

    var body: some View {
        RealityView { content in
            // First, the entity is loaded at the predefined distance from the user.
            content.add(entity)
            entity.transform = Transform(translation: audioSource.location + [0, heightOffset, 0])

            // We construct the visual representation here.
            switch audioSource.visualResourceLink {
            case .presetBox:
                // Making a simple box entity of colour blue (i.e., use the default).
                entity.addChild(defaultModel)
            case let .asset(assetName):
                // `assetName` should be the name of a USDZ file.
                if assetName != "" {
                    if let entityAsset = try? await Entity(named: assetName) {
                        if assetName == "Train_Speaker.usdz" {
                            entityAsset.scale *= 0.75
                        }
                        entityAsset.orientation = audioSource.orientation * entityAsset.orientation
                        entity.addChild(entityAsset)
                    }
                }
                // Make it empty otherwise.
            case let .animated(assetName):
                if let entityAsset = await makeAnimated(name: assetName) {
                    entityAsset.orientation = audioSource.orientation * entityAsset.orientation
                    entity.addChild(entityAsset)
                }
            case let .video(assetName):
                if let url = Bundle.main.url(forResource: assetName, withExtension: "mp4") {
                    let player = AVPlayer(url: url)
                    let material = VideoMaterial(avPlayer: player)
                    let videoPlane = ModelEntity(mesh: .generatePlane(width: 2.0, height: 1.2), materials: [material])
                    videoPlane.position = [0, 1.05, 0]
                    entity.addChild(videoPlane)
                    player.play()
                }
            }

            // Next, we determine whether we need to add the extra visual indicator or not.
            let currentQuestion = hearingTest.questions[questionNumber]
            let isFocused = currentQuestion.focus == audioSource.id

            // Attach the child `indicatorEntity` to be slightly above the object to be focused.
            let height: Float = audioSource.visualResourceLink == .asset("Train_Loudspeaker.usdz") ? 1.4 : 1.9
            self.indicatorEntity.position = [0, height, 0]
            if isFocused {
                entity.addChild(self.indicatorEntity)
            }
        } update: { content in
            /// All updates occur here.
            content.entities[0].transform = Transform(translation: audioSource.location + [0, heightOffset, 0])

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
            if isPlayingAudio {

                // Find the audio resource to load.
                let possibleAudio: String? = if isFocused {
                    newQuestion.chosenQuestion.audioResourceLink
                } else {
                    switch audioSource.type {
                    case let .conversation(audioName):
                        audioName ?? Presets.conversationAudioClips[0]
                    case let .ambient(audioName):
                        audioName ?? Presets.ambientAudioClips[0]
                    case .silent:
                        nil
                    }
                }

                guard let audioLink = possibleAudio else {
                    return
                }

                // Load the audio clip.
                guard let audio = try? AudioFileResource.load(
                    named: audioLink,
                    configuration: AudioFileResource.Configuration(shouldLoop: true)) else {
                    // Handle the error if the audio file fails to load. Stub for now.
                    print("Failed to load audio file.")
                    return
                }
                if content.entities[0].spatialAudio == nil {
                    // Set the spatial audio settings of the entity, attach it to the entity, and play the audio.
                    content.entities[0].spatialAudio = SpatialAudioComponent(directivity: .beam(focus: 0.2))
                    if isFocused {
                        print("Audio is playing.")
                    }
                    let audioController = content.entities[0].playAudio(audio)

                    // Set the clip to stop playing after the question's duration times out.
                    Task { @MainActor in
                        try? await Task.sleep(for: newQuestion.chosenQuestion.duration)
                        audioController.stop()
                        isPlayingAudio = false
                    }
                }
            } else {
                content.entities[0].spatialAudio = nil
            }
        }
    }

    func makeAnimated(name: String, anim: String = "default subtree animation", looping: Bool = true) async -> Entity? {
        guard let entity = try? await Entity(named: name) else {
            print("Cannot load animated entity.")
            return nil
        }
        guard let anim = entity
            .components[AnimationLibraryComponent.self]?
            .animations[anim] else {
            print("Cannot load animation.")
            return nil
        }
        let animation = looping ? anim.repeat() : anim
        entity.playAnimation(animation)
        return entity
    }
}
