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
    
    // Slow down the process of recognising speech
    @State private var numberDebounceTask: Task<Void, Never>? = nil
    
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
                historyState = .begin
            }
            .onChange(of: speechRec.speechContent) { _, newContent in
                print("Speech content: \(newContent)")
                voiceComHandler(newContent)
                print("state: \(historyState)")
            }
        }
    }

    @ViewBuilder
    private func scoreListView() -> some View {
        VStack {
            VStack {
                Text("History Log")
                    .font(.largeTitle)
                Text("View past scores on this device")
                    .font(.title)
                    .foregroundStyle(.secondary)
            }
            .padding()

            Spacer()
                .frame(height: 20)

            VStack {
                if savedScores.isEmpty {
                    Spacer()
                        .frame(height: 105)
                    Text("No attempts on this device yet.")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .padding()
                    Spacer()
                        .frame(height: 105)
                } else {
                    List {
                        ForEach(savedScores, id: \.id) { score in
                            Button {
                                scoreDetails = score
                                historyState = .detail
                            } label: {
                                HStack {
<<<<<<< Updated upstream
                                    Text("\(score.hearingTestName) (\(score.timeAttempted.formatted(date: .abbreviated, time: .shortened)))")
                                        .font(.title)
                                        .foregroundStyle(.secondary)
=======
                                    Text("\(score.hearingTestName) (\(scoreDetails.timeAttempted.formatted(date: .abbreviated, time: .shortened)))")
                                        .font(.headline)
>>>>>>> Stashed changes
                                        .padding(.vertical, 10)
                                    
                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.headline)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding()
        .overlay(alignment: .topLeading) {
            backButton {
                transition(from: "history-window", to: "main-window")
            }
        }
    }

    @ViewBuilder
    private func scoreDetailView() -> some View {
        VStack {
            VStack {
                Text(scoreDetails.hearingTestName)
                    .font(.largeTitle)

                Text(scoreDetails.timeAttempted.formatted(date: .abbreviated, time: .shortened))
                    .font(.title)
                    .foregroundStyle(.secondary)
            }
            .padding()

            Spacer()
                .frame(height: 20)

            let (correct, total) = scoreDetails.overallScore()
            Text("Score: \(correct) / \(total)")
                .font(.headline)
                .foregroundStyle(.secondary)

            List {
                ForEach(scoreDetails.answers, id: \.questionText) { answer in
                    HStack {
                        Image(systemName: answer.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(answer.isCorrect ? .green : .red)
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .padding()
                        VStack(alignment: .leading) {
                            Text(answer.questionText)
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            Text("Selected: \(answer.selectedAnswer)")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .frame(height: 300)
            .frame(width: 700)
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding()
        .overlay(alignment: .topLeading) {
            backButton {
                savedScores = PersistStorage.testStorage.loadScore()
                historyState = .begin
            }

        }
    }

    @MainActor
    private func transition(from: String, to: String) {
        Task { @MainActor in
            openWindow(id: to)
            try? await Task.sleep(for: .milliseconds(100))
            dismissWindow(id: from)
        }
    }

    /// Condensed the back bar and the back button into one method.
    @ViewBuilder
    private func backButton(action: @escaping () -> Void) -> some View {
        HStack {
            Button(action: action) {
                HStack {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                    Text("Back")
                        .font(.headline)
                }
                .padding()
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 20)
        .padding(.top, 20)
    }

    private func voiceComHandler(_ speech: String) {
        let voiceInput = speech.lowercased().components(separatedBy: .whitespaces).last ?? ""
        let words = speech.lowercased().components(separatedBy: .whitespaces)
        
        switch historyState {
        case .begin:
            if voiceInput.contains("back") {
                transition(from: "history-window", to: "main-window")
            }
            
            if let numberIndex = words.lastIndex(of: "number"), numberIndex + 1 < words.count {
                // Cancel previous debounce
                numberDebounceTask?.cancel()
                numberDebounceTask = Task {
                    try? await Task.sleep(for: .milliseconds(700))
                    guard !Task.isCancelled else { return }
                    
                    await MainActor.run {
                        let latestWords = speechRec.speechContent.lowercased()
                            .components(separatedBy: .whitespaces)
                        guard let latestNumberIndex = latestWords.lastIndex(of: "number"),
                              latestNumberIndex + 1 < latestWords.count,
                              case .begin = historyState else { return }
                        
                        let latestRemaining = Array(latestWords[(latestNumberIndex + 1)...])
                        if let number = parseSpokenNumber(latestRemaining),
                           number >= 1 && number <= savedScores.count {
                            let index = number - 1
                            scoreDetails = savedScores[index]
                            historyState = .detail
                        }
                    }
                }
            }
            
        case .detail:
            if voiceInput.contains("back") {
                historyState = .begin
            }
        }
    }
}
