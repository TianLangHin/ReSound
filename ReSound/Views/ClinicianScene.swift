//
//  ClinicianScene.swift
//  ReSound
//
//  Created by Tian Lang Hin on 3/4/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

import SwiftUI
import RealityKit

enum ClinicianState {
    case begin
    case edit(Int)
    case add
}

struct ClinicianScene: SwiftUI.Scene {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    @State var speechRec: SpeechRec

    @State var clinicianState: ClinicianState = .begin
    @State var customTest: CustomTest = .empty()
    @State var hearingTest: HearingTest = .empty()
    @State var isHearingTestOpened = false

    var body: some SwiftUI.Scene {
        WindowGroup(id: "clinician-window") {
            VStack {
                switch clinicianState {
                case .begin:
                    beginView()
                // The `.edit` variant is only usable once persistent storage is implemented,
                // and thus doesn't use the index right now.
                case .edit:
                    updateView()
                case .add:
                    updateView()
                }
            }
            .onAppear {
                hearingTest = customTest.generateTest()
            }
        }
        HearingTestScene(
            hearingTest: $hearingTest,
            isOpened: $isHearingTestOpened,
            speechRec: speechRec,
            hearingTestWindow: "practice-window",
            parentWindow: "clinician-window")
    }

    @ViewBuilder
    func beginView() -> some View {
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
                Task { @MainActor in
                    openWindow(id: "main-window")
                    try? await Task.sleep(for: .milliseconds(100))
                    dismissWindow(id: "clinician-window")
                }
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
    func updateView() -> some View {
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
                    Task { @MainActor in
                        isHearingTestOpened = true
                        openWindow(id: "practice-window")
                        try? await Task.sleep(for: .milliseconds(100))
                        dismissWindow(id: "clinician-window")
                    }
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
}
