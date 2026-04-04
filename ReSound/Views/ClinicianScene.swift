//
//  ClinicianScene.swift
//  ReSound
//
//  Created by Tian Lang Hin on 4/4/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

import SwiftUI

enum ClinicianState {
    case begin
    case edit(Int)
    case add
}

struct ClinicianScene: Scene {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    @State var speechRec: SpeechRec

    @State var clinicianState: ClinicianState = .begin
    @State var customTest: CustomTest = .init()
    @State var hearingTest: HearingTest = .init(
        name: "", audioSources: [], questions: [], backgroundResourceLink: "")

    @State var isHearingTestOpened = false

    var body: some Scene {
        WindowGroup(id: "clinician-window") {
            VStack {
                switch clinicianState {
                case .begin:
                    beginView()
                case .edit:
                    updateView()
                case .add:
                    updateView()
                }
            }
        }
        HearingTestScene(
            hearingTest: $hearingTest,
            isOpened: $isHearingTestOpened,
            speechRec: speechRec,
            hearingTestWindowId: "practice-window",
            parentWindowId: "clinician-window")
    }

    @ViewBuilder
    private func beginView() -> some View {
        VStack {
            Text("Hearing Test Customisation")
                .font(.system(size: 60))
                .padding()
            HStack {
                Button {
                    clinicianState = .edit(0)
                } label: {
                    Text("Edit Existing Test")
                        .font(.system(size: 30))
                        .padding()
                }
                .padding()
                Button {
                    clinicianState = .add
                } label: {
                    Text("Add New Hearing Test")
                        .font(.system(size: 30))
                        .padding()
                }
                .padding()
            }
            Button {
                transition(from: "clinician-window", to: "main-window")
            } label: {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Back")
                        .font(.system(size: 30))
                }
            }
            .padding()
        }
    }

    @ViewBuilder
    private func updateView() -> some View {
        HStack {
            VStack {
                Button {
                    clinicianState = .begin
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                            .font(.system(size: 30))
                    }
                }
                .padding()
                Spacer()
            }
            VStack {
                Button {
                    customTest.background = .home
                } label: {
                    Text("Home")
                        .font(.system(size: 40))
                        .padding()
                }
                .foregroundStyle(customTest.background == .home ? .green : .red)
                .padding()
                Button {
                    customTest.background = .cafe
                } label: {
                    Text("Café")
                        .font(.system(size: 40))
                        .padding()
                }
                .foregroundStyle(customTest.background == .cafe ? .green : .red)
                .padding()
                Button {
                    customTest.background = .train
                } label: {
                    Text("Train Station")
                        .font(.system(size: 40))
                        .padding()
                }
                .foregroundStyle(customTest.background == .train ? .green : .red)
                .padding()
            }
            VStack {
                Button {
                    customTest.positioning = .easy
                } label: {
                    Text("Easy")
                        .font(.system(size: 40))
                        .padding()
                }
                .foregroundStyle(customTest.positioning == .easy ? .green : .red)
                .padding()
                Button {
                    customTest.positioning = .medium
                } label: {
                    Text("Medium")
                        .font(.system(size: 40))
                        .padding()
                }
                .foregroundStyle(customTest.positioning == .medium ? .green : .red)
                .padding()
                Button {
                    customTest.positioning = .hard
                } label: {
                    Text("Hard")
                        .font(.system(size: 40))
                        .padding()
                }
                .foregroundStyle(customTest.positioning == .hard ? .green : .red)
                .padding()
                Slider(value: $customTest.targetVolume, in: -10.0 ... 0)
                    .frame(width: 250)
                    .padding()
                Stepper("Number of questions: \(customTest.numberOfQuestions)",
                    value: $customTest.numberOfQuestions, in: 1...5, step: 1)
                    .frame(width: 250)
                    .padding()
            }
            VStack {
                Button {
                    hearingTest = customTest.generateTest()
                    isHearingTestOpened = true
                    transition(from: "clinician-window", to: "practice-window")
                } label: {
                    Text("Practice Test")
                        .font(.system(size: 30))
                        .padding()
                }
                .padding()
                Spacer()
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
}
