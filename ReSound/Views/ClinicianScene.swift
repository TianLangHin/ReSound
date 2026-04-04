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
                transition(from: "main-window", to: "clinician-window")
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
        
    }

    @MainActor
    private func transition(from: String, to: String) {
        Task { @MainActor in
            openWindow(id: from)
            try? await Task.sleep(for: .milliseconds(100))
            dismissWindow(id: to)
        }
    }
}
