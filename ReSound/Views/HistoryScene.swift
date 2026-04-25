//
//  HistoryScene.swift
//  ReSound
//
//  Created by Dương Anh Trần on 20/4/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

import SwiftUI

enum HistoryState {
    case begin
    case detail
}

struct HistoryScene: Scene {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    @State var speechRec: SpeechRec
    @State var historyState: HistoryState = .begin
    @State var savedScores: [ScoreBreakdown] = PersistStorage.testStorage.loadScore()
    @State var scoreDetails: ScoreBreakdown = .empty()

    var body: some Scene {
        WindowGroup(id: "history-window") {
            VStack {
                switch historyState {
                case .begin:
                    scoreListView()
                case .detail:
                    scoreDetailView()
                }
            }
            .onAppear {
                savedScores = PersistStorage.testStorage.loadScore()
            }
            .onChange(of: speechRec.speechContent) { _, newContent in
                if newContent.lowercased().contains("back") {
                    transition(from: "history-window", to: "main-window")
                }
            }
        }
    }

    @ViewBuilder
    private func scoreListView() -> some View {
        VStack {
            historyBackBar {
                transition(from: "history-window", to: "main-window")
            }

            VStack {
                Text("Test History")
                    .font(.system(size: 60))
                    .bold()

                Text("View past hearing test scores on this device")
                    .font(.system(size: 30))
            }
            .frame(maxWidth: .infinity)
            .padding()

            Spacer()
                .frame(height: 30)

            VStack {
                if savedScores.isEmpty {
                    Text("No test attempts yet.")
                        .font(.system(size: 30))
                        .padding()
                } else {
                    List {
                        ForEach(savedScores, id: \.id) { score in
                            Button {
                                scoreDetails = score
                                historyState = .detail
                            } label: {
                                HStack {
                                    Text(score.hearingTestName)
                                        .font(.system(size: 30))
                                        .bold()
                                        .padding(.vertical, 10)

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 30))
                                }
                                .padding()
                            }
                        }
                        .onDelete { offsets in
                            savedScores.remove(atOffsets: offsets)
                            PersistStorage.testStorage.saveScore(savedScores)
                        }
                    }
                    .frame(height: 300)
                    .frame(width: 700)
                    .padding(.horizontal)
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
    }

    @ViewBuilder
    private func scoreDetailView() -> some View {
        VStack {
            historyBackBar {
                savedScores = PersistStorage.testStorage.loadScore()
                historyState = .begin
            }

            VStack {
                Text(scoreDetails.hearingTestName)
                    .font(.system(size: 60))
                    .bold()

                Text(scoreDetails.timeAttempted.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 30))
            }
            .frame(maxWidth: .infinity)
            .padding()

            Spacer()
                .frame(height: 30)

            let (correct, total) = scoreDetails.overallScore()
            Text("Score: \(correct) / \(total)")
                .font(.system(size: 35))
                .bold()

            List {
                ForEach(scoreDetails.answers, id: \.questionText) { answer in
                    HStack {
                        Image(systemName: answer.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(answer.isCorrect ? .green : .red)
                            .font(.system(size: 25))
                        VStack(alignment: .leading) {
                            Text(answer.questionText)
                                .font(.system(size: 25))
                                .bold()
                            Text("Selected: \(answer.selectedAnswer)")
                                .font(.system(size: 20))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .frame(width: 700)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
    }

    @MainActor
    private func transition(from: String, to: String) {
        Task { @MainActor in
            openWindow(id: to)
            try? await Task.sleep(for: .milliseconds(100))
            dismissWindow(id: from)
        }
    }

    // MARK: (similar method to `ClinicianScene`)

    @ViewBuilder
    private func backButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: "chevron.left")
                    .font(.system(size: 28))
                Text("Back")
                    .font(.system(size: 28))
                    .bold()
            }
            .foregroundStyle(.primary)
            .padding()
        }
    }

    @ViewBuilder
    private func historyBackBar(action: @escaping () -> Void) -> some View {
        HStack(spacing: 0) {
            backButton(action: action)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 20)
        .padding(.top, 20)
    }
}
