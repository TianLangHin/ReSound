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

    @State var isDisplayingImmersive = false
    @State var score = 0

    // This state is just to control some temporary buttons for exploring the prototype.
    @State var questionAdvanceText = "Next Question"

    // This should be a loaded asset, but for now is just a yellow sphere to indicate focus.
    let indicatorEntity = ModelEntity(mesh: MeshResource.generateSphere(radius: 0.1),
                                      materials: [UnlitMaterial(color: .systemYellow)])

    var body: some SwiftUI.Scene {
        WindowGroup {
            HStack {
                VStack {
                    // Opens the immersive space.
                    Button("Open") {
                        if !isDisplayingImmersive {
                            isDisplayingImmersive = true
                            Task {
                                await openImmersiveSpace(id: "test1")
                            }
                        }
                    }
                    .padding()
                    // Closes the immersive space.
                    Button("Close") {
                        if isDisplayingImmersive {
                            isDisplayingImmersive = false
                            Task {
                                await dismissImmersiveSpace()
                            }
                        }
                    }
                    .padding()
                    // Plays the hearing test question.
                    Button("Play") {
                        if !isPlaying {
                            isPlaying = true
                        }
                        Task {
                            let duration = Presets.hearingTests[hearingTestIndex].questions[questionNumber].duration
                            try? await Task.sleep(for: duration)
                            isPlaying = false
                            // The logic for window pop ups and further navigation can occur here.
                        }
                    }
                    .padding()
                    Text("\(isPlaying)")
                    // Resets and returns back to the first question.
                    Button {
                        if questionNumber < Presets.hearingTests[hearingTestIndex].questions.count - 1 {
                            // Loads the next question and increments the question number while that is valid.
                            questionNumber += 1
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
                        if !isPlaying {
                            questionNumber = 0
                            questionAdvanceText = "Next Question"
                            score = 0
                        }
                    } label: {
                        Text("Reset")
                            .font(.largeTitle)
                    }
                    .padding()
                }
                /// This is where the questions will show up.
                /// During the playing sound phase, it could be empty or a placeholder.
                VStack {
                    let currentQuestion = Presets.hearingTests[hearingTestIndex].questions[questionNumber].chosenQuestion
                    Text("Score: \(score)")
                        .font(.title)
                    if isDisplayingImmersive {
                        if isPlaying {
                            Text("Now playing audio for Question \(questionNumber + 1).")
                                .font(.largeTitle)
                        } else {
                            // This is where the question text and the corresponding answers can be displayed.
                            Text("Question: \(currentQuestion.question)")
                                .font(.largeTitle)
                            List {
                                ForEach(Array(currentQuestion.answers.enumerated()), id: \.offset) { index, answer in
                                    Button {
                                        let lastQuestion = Presets.hearingTests[hearingTestIndex].questions.count - 1
                                        // This logic should be tidied up/wrapped in a function later.
                                        // This handles whether to advance to a next question or not.
                                        if questionNumber <= lastQuestion {
                                            if questionNumber < lastQuestion {
                                                questionNumber += 1
                                                if currentQuestion.correctAnswer == index {
                                                    score += 1
                                                }
                                                isPlaying = true
                                            } else {
                                                questionAdvanceText = "Last Question Reached"
                                            }
                                        } else {
                                            questionAdvanceText = "Last Question Reached"
                                        }
                                    } label: {
                                        // The answers should not actually be colour-coded, but this is just a demonstration.
                                        Text("\(index + 1). \(answer)")
                                            .font(.largeTitle)
                                            .foregroundColor(index == currentQuestion.correctAnswer ? .green : .red)
                                    }
                                }
                            }
                        }
                    }
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
        .immersionStyle(selection: .constant(.full), in: .full)
    }
}
