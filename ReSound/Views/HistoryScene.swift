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
        }
    }
    
    
    
    private func scoreListView() -> some View {
        VStack {
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
                .tint(Color.red)
                
                Spacer()
            }
            
            Text("History")
                .font(.system(size: 60))
                .bold()
            
            Text("Choose your immersive testing environment")
                .font(.system(size: 30))
            
            Spacer()
                .frame(height: 50)
            
            VStack {
                if savedScores.isEmpty {
                    Text("No test attempt yet.")
                        .font(.system(size: 30))
                        .padding()
                } else {
                    List {
                        ForEach(savedScores, id: \.id) { score in
                            Button {
                                scoreDetails = score
                                historyState = .detail
                            } label: {
                                Text(score.hearingTestName)
                                    .font(.system(size: 30))
                                    .bold()
                                    .padding(.vertical, 25)
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
                .tint(.red)
                
                Spacer()
            }
            
            Text(scoreDetails.hearingTestName)
                .font(.system(size: 60))
                .bold()
            
            Text(scoreDetails.timeAttempted.formatted(date: .abbreviated, time: .shortened))
                .font(.system(size: 25))
                .foregroundStyle(.secondary)
            
            Spacer().frame(height: 30)
            
            let (correct, total) = scoreDetails.overallScore()
            Text("Score: \(correct) / \(total)")
                .font(.system(size: 35))
                .bold()
            
            Spacer().frame(height: 30)
            
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
            
            Spacer()
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
}
