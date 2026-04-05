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
    case waiting
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

    let hearingTestWindowId: String
    let parentWindowId: String

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
        WindowGroup(id: hearingTestWindowId) {
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
                case .waiting:
                    waitingView()
                case .ended:
                    endView()
                }
            }
            .padding()
            .onAppear {
                /// Toggling the Boolean binding for tracking in the parent view.
                isOpened = true
            }
            .onChange(of: speechRec.speechContent) { _, newContent in
                DispatchQueue.main.async {
                    print("Speech content: \(newContent)")
                    print("Question state: \(questionState)")
                    if questionState == .waiting {
                        if newContent.lowercased().contains("next") {
                            moveFromWaiting()
                        }
                    } else if questionState == .answering {
                        let currentQuestion = hearingTest.questions[questionNumber]
                        validateSpeechContent(newContent, question: currentQuestion.chosenQuestion)
                    } else if questionState == .ended {
                        if newContent.lowercased().contains("exit") {
                            exitEntirely()
                        }
                    }
                }
            }
            .onChange(of: questionState) {
                print("Question state: \(questionState)")
            }
        }
        /// The immersive space is where the hearing test happens via spatial audio.
        ImmersiveSpace(id: hearingTestWindowId + "-immersive") {
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

    /// Function to return to the main menu (exiting the patient view).
    private func exitEntirely() {
        // Stops the speech recording before exiting.
        speechRec.stopRec()
        // Here, the window is dismissed and the state is reset
        // so another test can be administered after this.
        closeSpace()
        reset()
        /// An asynchronous task on the main queue is used to load the other window,
        /// wait for 100 milliseconds to ensure the system can recognise it is open,
        /// and then close the previous window (which is only successful if another window is open).
        Task { @MainActor in
            openWindow(id: parentWindowId)
            try? await Task.sleep(for: .milliseconds(100))
            isOpened = false
            dismissWindow(id: hearingTestWindowId)
        }
    }

    /// Function to validate the content of the speech.
    private func validateSpeechContent(_ content: String, question: PossibleQuestion) {
        let normalisedContent = content.lowercased()
        // Trigger words include the digit versions of the option numbers as well,
        // to account for all possibilities of speech content detected by the speech recognition module.
        let answersDictionary = ["one": 0, "two": 1, "three": 2, "four": 3, "1": 0, "2": 1, "3": 2, "4": 3]

        // Search for the first trigger word + match it with the index
        guard let matchingKey = answersDictionary.keys.first(where: { normalisedContent.contains($0) }) else {
            return
        }
        guard let index = answersDictionary[matchingKey] else {
            return
        }

        print("Answer chosen is \(question.answers[index])")
        advanceQuestion(answer: index)
    }

    /// A separate function is needed to construct the visual entity
    /// as it is disallowed inline in the immersive space.
    private func makeIndicatorEntity() -> Entity {
//        return ModelEntity( //need to rotate by 180 degrees. And size it correctly
//            mesh: MeshResource.generateCone(height: 0.2, radius: 0.1),
//            materials: [UnlitMaterial(color: .systemYellow)])
        
        let indicatorEntity = ModelEntity(
            mesh: .generateCone(height: 0.1, radius: 0.05),
            materials: [UnlitMaterial(color: .systemYellow)]
        )
        indicatorEntity.orientation = simd_quatf(angle: .pi, axis: [0, 0, 1]) // rotate 180 degrees to point cone downward
        return indicatorEntity
    }

    /// Each of the next four functions are SwiftUI Views, encapsulated for neater code.

    @ViewBuilder
    private func startView() -> some View {
        VStack {
            Button {
                openSpace()
                startQuestion(firstCall: true)
            } label: {
                Text("Start hearing test!")
                    .padding()
                    .font(.title2)
            }
            .padding()
            Button {
                exitEntirely()
            } label: {
                Text("Exit entirely")
                    .padding()
                    .font(.title2)
            }
            .padding()
        }
    }

    @ViewBuilder
    private func playingView() -> some View {
        Text("Audio for Question \(questionNumber + 1) is playing.")
            .font(.system(size: 60))
            .padding()
    }

    @ViewBuilder
    private func questionChoiceView() -> some View {
        let currentQuestion = hearingTest.questions[questionNumber].chosenQuestion
        VStack {
            Text(currentQuestion.question)
                .font(.title3)
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
    private func waitingView() -> some View {
        VStack {
            Text("Continue on to Question \(questionNumber + 2)?")
                .font(.system(size: 60))
                .padding()
            Button {
                // Question advancement is delayed so that the visual pointer
                // is revealed only when the question starts.
                moveFromWaiting()
            } label: {
                Text("Continue")
                    .font(.title3)
                    .padding()
            }
        }
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
                Text("Exit immersive space")
                    .font(.title3)
            }
            Button {
                exitEntirely()
            } label: {
                Text("Exit back to main menu")
                    .padding()
                    .font(.title2)
            }
            .padding()
        }
        .padding()
    }

    private func moveFromWaiting() {
        questionNumber += 1
        startQuestion()
    }

    /// Plays an audio question and updates the state so the window group is updated too.
    /// The optional argument `firstCall` indicates whether this is the first time
    /// `startQuestion` is being called.
    /// That corresponds to the transition of `questionState` from `.before` to `.playing`.
    private func startQuestion(firstCall: Bool = false) {
        if !isPlayingAudio {
            let questionDuration = hearingTest.questions[questionNumber].chosenQuestion.duration
            isPlayingAudio = true
            questionState = .playing
            if !firstCall {
                speechRec.stopRec()
            }
            Task { @MainActor in
                try? await Task.sleep(for: questionDuration)
                stopQuestion()
            }
        }
    }

    private func stopQuestion() {
        if isPlayingAudio {
            isPlayingAudio = false
            questionState = .answering
            try? speechRec.startRec()
        }
    }

    /// This logic manages whether the test has ended or not,
    /// as well as advancement to the next question (if it exists).
    private func advanceQuestion(answer: Int) {
        let lastQuestionNumber = hearingTest.questions.count - 1
        if questionNumber < lastQuestionNumber {
            registerAnswer(choice: answer)
            questionState = .waiting
        } else {
            if questionNumber == lastQuestionNumber {
                registerAnswer(choice: answer)
            }
            questionState = .ended
            try? speechRec.startRec()
        }
    }

    /// Registers an answer of a particular question from the user.
    private func registerAnswer(choice: Int) {
        let correctAnswer = hearingTest.questions[questionNumber].chosenQuestion.correctAnswer
        if choice == correctAnswer {
            score += 1
        }
    }

    private func openSpace() {
        if !isDisplayingImmersive {
            Task {
                await openImmersiveSpace(id: hearingTestWindowId + "-immersive")
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
        speechRec.stopRec()
    }
}

