//
//  HearingTestWindowView.swift
//  ReSound
//
//  Window UI for the hearing test (patient) flow, extracted for Canvas previews.
//

import SwiftUI

struct HearingTestWindowView: View {
    let hearingTest: HearingTest
    let questionState: QuestionState
    let questionNumber: Int
    let score: Int

    var onStartTest: () -> Void
    var onExit: () -> Void
    var onAnswer: (Int) -> Void
    var onContinueWaiting: () -> Void
    var onExitImmersiveOnly: () -> Void
    var onExitToMenu: () -> Void

    var body: some View {
        VStack(spacing: ReSoundLayout.sectionSpacing) {
            switch questionState {
            case .before:
                startView
            case .playing:
                playingView
            case .answering:
                questionChoiceView
            case .waiting:
                waitingView
            case .ended:
                endView
            }
        }
        .padding(ReSoundLayout.cardPadding)
    }

    private var startView: some View {
        VStack(spacing: ReSoundLayout.sectionSpacing) {
            Text("Start Test: \(hearingTest.name)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            Text("Start the hearing test when you're ready!")
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button(action: onStartTest) {
                Text("Start hearing test!")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .frame(maxWidth: 500)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityHint("Opens the immersive space and begins the first question")

            Button(action: onExit) {
                Text("Exit")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .frame(minWidth: 150)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.bordered)
            .accessibilityLabel("Exit")
            .accessibilityHint("Closes the hearing test and returns to the previous window")
        }
    }

    private var playingView: some View {
        Text("Audio for Question \(questionNumber + 1) is playing.")
            .font(.title2)
            .fontWeight(.semibold)
            .multilineTextAlignment(.center)
            .accessibilityLabel("Audio for question \(questionNumber + 1) is playing")
    }

    private var questionChoiceView: some View {
        let currentQuestion = hearingTest.questions[questionNumber].chosenQuestion
        return VStack(alignment: .leading, spacing: ReSoundLayout.stackSpacing) {
            Text(currentQuestion.question)
                .font(.title3)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            List {
                ForEach(Array(currentQuestion.answers.enumerated()), id: \.offset) { index, answer in
                    Button {
                        onAnswer(index)
                    } label: {
                        Text("\(index + 1). \(answer)")
                            .font(.body)
                    }
                    .accessibilityLabel("Answer \(index + 1): \(answer)")
                }
            }
        }
    }

    private var waitingView: some View {
        VStack(spacing: ReSoundLayout.stackSpacing) {
            Text("Continue on to Question \(questionNumber + 2)?")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            Button(action: onContinueWaiting) {
                Text("Continue")
                    .font(.body)
                    .fontWeight(.semibold)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityHint("Proceeds to the next question")
        }
    }

    private var endView: some View {
        let questionCount = hearingTest.questions.count
        return VStack(spacing: ReSoundLayout.stackSpacing) {
            Text("Score: \(score) out of \(questionCount)")
                .font(.title)
                .fontWeight(.bold)
                .accessibilityLabel("Your score is \(score) out of \(questionCount)")
            Button(action: onExitImmersiveOnly) {
                Text("Exit immersive space")
                    .font(.body)
                    .fontWeight(.medium)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.bordered)
            .accessibilityHint("Closes the immersive environment but keeps this window open")
            Button(action: onExitToMenu) {
                Text("Exit back to main menu")
                    .font(.body)
                    .fontWeight(.semibold)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityHint("Returns to the main menu")
        }
    }
}

#if DEBUG
#Preview("Start") {
    HearingTestWindowView(
        hearingTest: Presets.hearingTests[0],
        questionState: .before,
        questionNumber: 0,
        score: 0,
        onStartTest: {},
        onExit: {},
        onAnswer: { _ in },
        onContinueWaiting: {},
        onExitImmersiveOnly: {},
        onExitToMenu: {}
    )
}

#Preview("Answering") {
    HearingTestWindowView(
        hearingTest: Presets.hearingTests[0],
        questionState: .answering,
        questionNumber: 0,
        score: 0,
        onStartTest: {},
        onExit: {},
        onAnswer: { _ in },
        onContinueWaiting: {},
        onExitImmersiveOnly: {},
        onExitToMenu: {}
    )
}

#Preview("Ended") {
    HearingTestWindowView(
        hearingTest: Presets.hearingTests[0],
        questionState: .ended,
        questionNumber: 1,
        score: 1,
        onStartTest: {},
        onExit: {},
        onAnswer: { _ in },
        onContinueWaiting: {},
        onExitImmersiveOnly: {},
        onExitToMenu: {}
    )
}
#endif
