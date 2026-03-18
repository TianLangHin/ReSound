/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The app's main entry point.
*/

import SwiftUI
import RealityKit

@main
struct EntryPoint: App {
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    /// States to control whether the audio questions are playing,
    /// which hearing test is being used,
    /// and which question within that hearing test is playing.
    @State var isPlaying = false
    @State var hearingTestIndex = 0
    @State var questionNumber = 0

    // This state is just to control some temporary buttons for exploring the prototype.
    @State var questionAdvanceText = "Next Question"

    let indicatorEntity = ModelEntity(mesh: MeshResource.generateSphere(radius: 0.1),
                                      materials: [UnlitMaterial(color: .systemYellow)])
    var body: some SwiftUI.Scene {
        WindowGroup {
            HStack {
                // Opens the immersive space.
                Button("Open") {
                    Task {
                        await openImmersiveSpace(id: "test1")
                    }
                }
                .padding()
                // Closes the immersive space.
                Button("Close") {
                    Task {
                        await dismissImmersiveSpace()
                    }
                }
                .padding()
                // Plays the hearing test question.
                Button("Play") {
                    isPlaying = true
                    Task {
                        let duration = Presets.hearingTests[hearingTestIndex].questions[questionNumber].duration
                        try? await Task.sleep(for: duration)
                        isPlaying = false
                        // The logic for window pop ups and further navigation can occur here.
                    }
                }
                .padding()
                // Resets and returns back to the first question.
                Button {
                    if questionNumber < Presets.hearingTests[hearingTestIndex].questions.count - 1 {
                        // Loads the next question and increments the question number while that is valid.
                        questionNumber += 1
                        loadNextQuestion()
                    } else {
                        questionAdvanceText = "Last Question Reached"
                    }
                } label: {
                    HStack {
                        Text(questionAdvanceText)
                            .font(.largeTitle)
                            .padding()
                        Text("\(questionNumber)")
                    }
                }
                .padding()
                // Resets the question number back to 0.
                Button {
                    questionNumber = 0
                    questionAdvanceText = "Next Question"
                    loadNextQuestion()
                } label: {
                    Text("Reset")
                        .font(.largeTitle)
                }
                .padding()
            }
        }
        /// Displays the immersive space in a mixed style so that the reset
        /// of the immersion does not cause lag or drastic visual changes.
        ImmersiveSpace(id: "test1") {
            let hearingTest = Presets.hearingTests[hearingTestIndex]
            // The audio sources need to be rendered by hash so that it is refreshed correctly.
            ForEach(hearingTest.audioSources, id: \.self) { audioSource in
                AudioSourceView(audioSource: audioSource,
                                hearingTest: hearingTest,
                                questionNumber: $questionNumber,
                                isPlayingAudio: $isPlaying,
                                indicatorEntity: indicatorEntity)
            }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }

    /// Uses the dismissing and opening of the immersive space to force the entity updates.
    func loadNextQuestion() {
        /*
        Task {
            await dismissImmersiveSpace()
            await openImmersiveSpace(id: "test1")
        }
         */
    }
}
