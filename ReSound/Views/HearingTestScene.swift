//
//  HearingTestScene.swift
//  ReSound
//
//  Created by Tian Lang Hin on 22/3/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

import SwiftUI
import RealityKit

enum QuestionState {
    case before
    case playing
    case answering
    case ended
}

/// The Scene through which the hearing test (in the patient view) is administered.
struct HearingTestScene: SwiftUI.Scene {
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    /// This is bound to a particular `HearingTest` instance managed outside this scene,
    /// and will toggle an "isOpened" indicator to notify the parent view.
    @Binding var hearingTest: HearingTest
    @Binding var isOpened: Bool

    @State var speechRec: SpeechRec

    /// At the start, the user has yet to play a question, no audio is played,
    /// and the scene starts from the very first question.
    @State var questionState: QuestionState = .before
    @State var questionNumber = 0
    @State var isPlayingAudio = false
    @State var score = 0

    /// Used to keep track of immersive display status.
    @State var isDisplayingImmersive = false

    var body: some SwiftUI.Scene {
        /// The ID of this window group is referenced in the outer parent view.
        WindowGroup(id: "hearing-test-window") {
            VStack {
                /// The display on the window group inside the hearing test
                /// depends on whether the user is at the start (no questions played yet),
                /// audio is currently playing (in which case we do not show the answers),
                /// audio has finished playing (here we show the question/answers),
                /// and whether the test has ended (then we show the score).
                switch questionState {
                case .before:
                    startView()
                case .playing:
                    playingView()
                case .answering:
                    questionChoiceView()
                case .ended:
                    endView()
                }
                Button {
                    /// Here, the window is dismissed and the state is reset
                    /// so another test can be administered after this.
                    closeSpace()
                    reset()
                    openWindow(id: "main-window")
                    isOpened = false
                    dismissWindow(id: "hearing-test-window")
                } label: {
                    Text("Exit entirely")
                        .padding()
                        .font(.title2)
                }
                .padding()
                Button {
                    dismissWindow(id: "main-window")
                } label: {
                    Text("Close main view")
                        .padding()
                        .font(.title2)
                }
                .padding()
            }
            .padding()
            .onAppear {
                /// Toggling the Boolean binding for tracking in the parent view.
                isOpened = true
            }
            .onChange(of: speechRec.speechContent) { _, newContent in
                let currentQuestion = hearingTest.questions[questionNumber]
                validateSpeechContent(newContent, question: currentQuestion.chosenQuestion)
            }
        }
        /// The immersive space is where the hearing test happens via spatial audio.
        ImmersiveSpace(id: "hearing-test-immersive") {
            let indicatorEntity = makeIndicatorEntity()
            /// Surrounding the user will be a skybox as a sphere to project the EXR/HDR image.
            SkyboxView(resourceName: hearingTest.backgroundResourceLink)
            /// Each of the audio sources as designated by the `HearingTest` instance will be placed in the space.
            ForEach(hearingTest.audioSources, id: \.self) { audioSource in
                AudioSourceView(audioSource: audioSource,
                                hearingTest: hearingTest,
                                questionNumber: $questionNumber,
                                isPlayingAudio: $isPlayingAudio,
                                indicatorEntity: indicatorEntity)
            }
        }
        .immersionStyle(selection: .constant(.full), in: .full)
    }

    /// Function to validate the content of the speech
    private func validateSpeechContent(_ content: String, question: PossibleQuestion) {
        let normalisedContent = content.lowercased()
        let triggerWords = ["one", "two", "three", "four"]
        let answersDictionary = ["one": 0, "two": 1, "three": 2, "four": 3]

        // Search for the first trigger word + match it with the index
        guard let matchedWord = triggerWords.first(where: { normalisedContent.contains($0) }),
              let index = answersDictionary[matchedWord] else {
            return
        }

        print("Answer chosen is \(question.answers[index])")
        advanceQuestion(answer: index)
    }

    /// A separate function is needed to construct the visual entity
    /// as it is disallowed inline in the immersive space.
    private func makeIndicatorEntity() -> Entity {
        if let arrowEntity = try? Entity.load(named: "Car_Arrow.usdz") {
            // The arrow entity is big and points outward, so adjustments are made.
            arrowEntity.scale *= 0.03
            arrowEntity.orientation = simd_quatf(angle: 3 * .pi / 2, axis: [1, 0, 0])
            return arrowEntity
        } else {
            // The default is just the yellow sphere.
            return ModelEntity(
                mesh: MeshResource.generateSphere(radius: 0.1),
                materials: [UnlitMaterial(color: .systemYellow)])
        }
    }

    /// Each of the next four functions are SwiftUI Views, encapsulated for neater code.

    @ViewBuilder
    private func startView() -> some View {
        Button {
            openSpace()
            startQuestion()
        } label: {
            Text("Start hearing test!")
                .padding()
                .font(.title2)
        }
        .padding()
    }

    @ViewBuilder
    private func playingView() -> some View {
        let currentQuestion = hearingTest.questions[questionNumber].chosenQuestion
        VStack {
            Text("Audio for Question \(questionNumber + 1) is playing.")
                .font(.title2)
                .padding()
            Text("The question is: \(currentQuestion.question)")
                .font(.title2)
                .padding()
        }
    }

    @ViewBuilder
    private func questionChoiceView() -> some View {
        let currentQuestion = hearingTest.questions[questionNumber].chosenQuestion
        VStack {
            Text(currentQuestion.question)
                .font(.title2)
                .padding()
            List {
                ForEach(Array(currentQuestion.answers.enumerated()), id: \.offset) { index, answer in
                    Button {
                        advanceQuestion(answer: index)
                    } label: {
                        Text("\(index + 1). \(answer)")
                            .font(.title2)
                    }
                    .padding()
                }
            }
        }
        .padding()
    }

    @ViewBuilder
    private func endView() -> some View {
        let questionCount = hearingTest.questions.count
        VStack {
            Text("Score: \(score) out of \(questionCount)")
                .font(.system(size: 48))
                .padding()
            Button {
                closeSpace()
            } label: {
                Text("Return to main menu")
                    .font(.title3)
            }
        }
        .padding()
    }

    /// Plays an audio question and updates the state so the window group is updated too.
    private func startQuestion() {
        let questionDuration = hearingTest.questions[questionNumber].duration
        isPlayingAudio = true
        questionState = .playing
        Task {
            try? await Task.sleep(for: questionDuration)
            stopQuestion()
        }
    }

    private func stopQuestion() {
        isPlayingAudio = false
        questionState = .answering
        try? speechRec.startRec()
    }

    /// This logic manages whether the test has ended or not,
    /// as well as advancement to the next question (if it exists).
    private func advanceQuestion(answer: Int) {
        let lastQuestionNumber = hearingTest.questions.count - 1
        if questionNumber < lastQuestionNumber {
            registerAnswer(choice: answer)
            questionNumber += 1
            questionState = .playing
            startQuestion()
        } else {
            if questionNumber == lastQuestionNumber {
                registerAnswer(choice: answer)
            }
            questionState = .ended
        }
        speechRec.stopRec()
    }

    /// Registers an answer of a particular question from the user.
    private func registerAnswer(choice: Int) {
        speechRec.stopRec()
        let correctAnswer = hearingTest.questions[questionNumber].chosenQuestion.correctAnswer
        if choice == correctAnswer {
            score += 1
        }
    }

    private func openSpace() {
        if !isDisplayingImmersive {
            Task {
                await openImmersiveSpace(id: "hearing-test-immersive")
                isDisplayingImmersive = true
            }
        }
    }

    private func closeSpace() {
        if isDisplayingImmersive {
            Task {
                await dismissImmersiveSpace()
                isDisplayingImmersive = false
            }
        }
    }

    /// Resets state so that the space can be reused for another hearing test.
    private func reset() {
        questionState = .before
        questionNumber = 0
        isPlayingAudio = false
        score = 0
        isDisplayingImmersive = false
    }
}
