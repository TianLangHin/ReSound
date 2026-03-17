/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A RealityKit view that plays spatial audio.
*/

import SwiftUI
import RealityKit

/// A view that plays spatial audio that responds to changes in rotation translation of both the source and the listener.
struct SpatialAudioView: View {
    /// The arguments to this view are the `TestAudioSource` instance used as a template to build it.
    /// and a binding boolean indicator of whether it is focused or not so it can be adjusted without reconstruction.
    let testAudioSource: TestAudioSource
    @Binding var isFocused: Bool
    @Binding var question: AudioQuestion?

    /// The entity to contain the audio sample.
    let entity = Entity()

    @State var audioController: AudioPlaybackController? = nil

    /// The main body view that includes the audio source only and potentially a visual indicator.
    var body: some View {
        HStack {
            audioSource
        }
        .onChange(of: question) { _, newValue in
            if newValue != nil {
                startQuestion(question: newValue!)
            } else {
                stopQuestion()
            }
        }
    }

    /// A view that loads and configures the audio source as an ambient audio entity.
    var audioSource: some View {
        RealityView { content in
            // Add the entity to the `RealityView`.
            content.add(entity)
            // Set the location.
            entity.transform = Transform(translation: testAudioSource.location)

            // We construct the visual representation here.
            switch testAudioSource.visualResourceLink {
            case .presetBox:
                // Making a simple box entity of colour red.
                let mesh = MeshResource.generateBox(size: [0.3, 0.3, 0.3])
                let material = UnlitMaterial(color: .systemRed)
                let boxEntity = ModelEntity(mesh: mesh, materials: [material])
                entity.addChild(boxEntity)
            case .asset:
                // Just a stub function for now. This should load a model from the Assets.
                entity.addChild(AxisVisualizer.make())
            }

            // After that, if the entity is being visually focused, add another visual indicator.
            if isFocused {
                let mesh = MeshResource.generateSphere(radius: 0.1)
                let material = UnlitMaterial(color: .systemYellow)
                let indicatorEntity = ModelEntity(mesh: mesh, materials: [material])
                // Attach the child `indicatorEntity` to be slightly above the object to be focused.
                indicatorEntity.position = [0, 0.2, 0]
                entity.addChild(indicatorEntity)
            }
        }
    }

    /// This function is to be called immediately upon the start of a question,
    /// allowing a single `SpatialAudioView` to be created once and reused for the entire test.
    public func startQuestion(question: AudioQuestion) {
        // Load the audio clip.
        guard let audio = try? AudioFileResource.load(
            named: question.audioResourceLink,
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
            try? await Task.sleep(for: question.duration)
            self.audioController?.stop()
            // Loading the question view after this will be the next task.
        }
    }

    func stopQuestion() {
        self.audioController?.stop()
    }
}
