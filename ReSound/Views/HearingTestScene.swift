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

struct HearingTestScene: SwiftUI.Scene {
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    @Binding var hearingTest: HearingTest
    @Binding var isOpened: Bool

    @State var speechRec: SpeechRec

    @State var questionState: QuestionState = .before
    @State var questionNumber = 0
    @State var isPlayingAudio = false
    @State var score = 0

    @State var isDisplayingImmersive = false

    var body: some SwiftUI.Scene {
        WindowGroup(id: "hearing-test-window") {
            VStack {
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
                    closeSpace()
                    reset()
                    isOpened = false
                    dismissWindow(id: "hearing-test-window")
                } label: {
                    Text("Exit entirely")
                        .padding()
                        .font(.title2)
                }
                .padding()
            }
            .padding()
            .onAppear {
                isOpened = true
            }
        }
        ImmersiveSpace(id: "hearing-test-immersive") {
            // This should be a loaded asset, but for now is just a yellow sphere to indicate focus.
            let indicatorEntity = ModelEntity(
                mesh: MeshResource.generateSphere(radius: 0.1),
                materials: [UnlitMaterial(color: .systemYellow)])
            SkyboxView(resourceName: hearingTest.backgroundResourceLink)
            ForEach(hearingTest.audioSources, id: \.self) { audioSource in
                AudioSourceView(audioSource: audioSource,
                                hearingTest: hearingTest,
                                speechRec: speechRec, questionNumber: $questionNumber,
                                isPlayingAudio: $isPlayingAudio,
                                indicatorEntity: indicatorEntity)
            }
        }
        .immersionStyle(selection: .constant(.full), in: .full)
    }

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
        Text("Audio for Question \(questionNumber + 1) is playing.")
            .font(.title2)
            .padding()
    }

    @ViewBuilder
    private func questionChoiceView() -> some View {
        let currentQuestion = hearingTest.questions[questionNumber].chosenQuestion
        List {
            ForEach(Array(currentQuestion.answers.enumerated()), id: \.offset) { index, answer in
                Button {
                    let lastQuestionNumber = hearingTest.questions.count - 1
                    if questionNumber < lastQuestionNumber {
                        registerAnswer(choice: index)
                        questionNumber += 1
                        questionState = .playing
                        startQuestion()
                    } else {
                        if questionNumber == lastQuestionNumber {
                            registerAnswer(choice: index)
                        }
                        questionState = .ended
                    }
                } label: {
                    Text("\(index + 1). \(answer)")
                        .font(.title2)
                        .padding()
                }
            }
        }
        .padding()
    }

    @ViewBuilder
    private func endView() -> some View {
        VStack {
            Text("Score: \(score)")
                .font(.title2)
                .padding()
            Button {
                closeSpace()
            } label: {
                Text("Return to main menu")
                    .font(.title2)
            }
        }
        .padding()
    }

    private func startQuestion() {
        let questionDuration = hearingTest.questions[questionNumber].duration
        isPlayingAudio = true
        Task {
            try? await Task.sleep(for: questionDuration)
            isPlayingAudio = false
            questionState = .answering
        }
    }

    private func registerAnswer(choice: Int) {
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

    private func reset() {
        questionState = .before
        questionNumber = 0
        isPlayingAudio = false
        score = 0
        isDisplayingImmersive = false
    }
}
