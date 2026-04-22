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

    private func scoreListView() -> some View {
        VStack {
            ZStack {
                VStack {
                    Text("Test History")
                        .font(.system(size: 60))
                        .bold()
                    
                    Text("View past hearing test scores on this device")
                        .font(.system(size: 30))
                }
                .padding()
                
                HStack {
                    Button {
                        transition(from: "history-window", to: "main-window")
                    } label: {
                        HStack {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 30))
                            Text("Back")
                                .font(.system(size: 30))
                                .bold()
                        }
                        .padding()
                    }
                    Spacer()
                }
            }

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
        .padding()
    }

    private func scoreDetailView() -> some View {
        VStack {
            ZStack {
                VStack {
                    Text(scoreDetails.hearingTestName)
                        .font(.system(size: 60))
                        .bold()
                    
                    Text(scoreDetails.timeAttempted.formatted(date: .abbreviated, time: .shortened))
                        .font(.system(size: 30))
                }
                .padding()
                
                HStack {
                    Button {
                        savedScores = PersistStorage.testStorage.loadScore()
                        historyState = .begin
                    } label: {
                        HStack {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 30))
                            Text("Back")
                                .font(.system(size: 30))
                                .bold()
                        }
                        .padding()
                    }
                    Spacer()
                }
            }
            
            Spacer()
                .frame(height: 30)
            
            let (correct, total) = scoreDetails.overallScore()
            Text("Score: \(correct) / \(total)")
                .font(.system(size: 35))
                .bold()
            
            /// Not sure if this spacer is necessary but we'll see if we need to add it back in
            ///Spacer().frame(height: 30)
            
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
