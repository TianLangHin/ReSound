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

    @State var savedTests: [HearingTest] = PersistStorage.testStorage.loadTest()
    @State var savedCustoms: [CustomTest] = PersistStorage.testStorage.loadCustom()

    var body: some Scene {
        WindowGroup(id: "clinician-window") {
            VStack(spacing: ReSoundLayout.sectionSpacing) {
                switch clinicianState {
                case .begin:
                    beginView()
                case .edit:
                    updateView()
                case .add:
                    updateView()
                }
            }
            .padding(ReSoundLayout.cardPadding)
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
        VStack(spacing: ReSoundLayout.sectionSpacing) {
            Text("Hearing Test Customisation")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            HStack(alignment: .top, spacing: ReSoundLayout.sectionSpacing) {
                // Testing for storage showing
                if savedTests.isEmpty {
                    Text("No saved tests yet.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, minHeight: 120, alignment: .center)
                } else {
                    List {
                        ForEach(savedTests, id: \.name) { test in
                            Button(action: {
                                if let index = savedTests.firstIndex(where: { $0.name == test.name }) {
                                    customTest = savedCustoms[index]
                                    clinicianState = .edit(index)
                                }
                            }) {
                                Text(test.name)
                                    .font(.body)
                            }
                            .accessibilityLabel("Saved test: \(test.name)")
                        }
                        .onDelete { offsets in
                            savedTests.remove(atOffsets: offsets)
                            savedCustoms.remove(atOffsets: offsets)
                            PersistStorage.testStorage.saveTest(savedTests)
                            PersistStorage.testStorage.saveCustom(savedCustoms)
                        }
                    }
                    .frame(height: 300)
                    .frame(width: 700)
                }

                Button {
                    // Set name for the new test saving because no text field
                    customTest.name = "Custom Test \(savedTests.count + 1)"
                    clinicianState = .add
                } label: {
                    Text("Add New Hearing Test")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(ReSoundLayout.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: ReSoundLayout.cardCornerRadius)
                    .fill(.ultraThinMaterial)
            )

            Button {
                transition(from: "clinician-window", to: "main-window")
            } label: {
                Label("Back", systemImage: "chevron.backward")
                    .font(.body)
                    .fontWeight(.medium)
            }
            .buttonStyle(.bordered)
            .accessibilityHint("Returns to the main menu window")
        }
    }

    @ViewBuilder
    private func updateView() -> some View {
        HStack(alignment: .top, spacing: ReSoundLayout.sectionSpacing) {
            VStack(alignment: .leading, spacing: ReSoundLayout.stackSpacing) {
                Button {
                    clinicianState = .begin
                } label: {
                    Label("Back", systemImage: "chevron.backward")
                        .font(.body)
                        .fontWeight(.medium)
                }
                .buttonStyle(.bordered)
                .accessibilityHint("Returns to the saved tests list")
                Spacer()
            }
            .frame(width: 140, alignment: .leading)

            VStack(alignment: .leading, spacing: ReSoundLayout.stackSpacing) {
                Text("Environment")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                environmentButton(.home, title: "Home")
                environmentButton(.cafe, title: "Café")
                environmentButton(.train, title: "Train Station")
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: ReSoundLayout.stackSpacing) {
                Text("Difficulty")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                positioningButton(.easy, title: "Easy")
                positioningButton(.medium, title: "Medium")
                positioningButton(.hard, title: "Hard")
                VStack(alignment: .leading, spacing: 8) {
                    Text("Target volume")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Slider(value: $customTest.targetVolume, in: -10.0 ... 0)
                        .frame(width: 250)
                        .accessibilityLabel("Target volume")
                }
                .padding(.top, 4)
                Stepper(value: $customTest.numberOfQuestions, in: 1...5, step: 1) {
                    Text("Number of questions: \(customTest.numberOfQuestions)")
                        .font(.body)
                }
                .frame(width: 280)
                .accessibilityLabel("Number of questions")
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: ReSoundLayout.stackSpacing) {
                Button {
                    hearingTest = customTest.generateTest()
                    isHearingTestOpened = true
                    transition(from: "clinician-window", to: "practice-window")
                } label: {
                    Text("Practice Test")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityHint("Opens a practice window with the generated test")

                Button {
                    let test = customTest.generateTest()
                    switch clinicianState {
                    case .edit(let index):
                        savedTests[index] = test
                        savedCustoms[index] = customTest
                    case .add:
                        savedTests.append(test)
                        savedCustoms.append(customTest)
                    case .begin:
                        break
                    }
                    PersistStorage.testStorage.saveTest(savedTests)
                    PersistStorage.testStorage.saveCustom(savedCustoms)
                    clinicianState = .begin
                } label: {
                    Text("Save Test")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.bordered)
                Spacer()
            }
            .frame(width: 200)
        }
        .padding(ReSoundLayout.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: ReSoundLayout.cardCornerRadius)
                .fill(.ultraThinMaterial)
        )
    }

    @ViewBuilder
    private func environmentButton(_ theme: CustomTest.Theme, title: String) -> some View {
        let isSelected = customTest.background == theme
        Button {
            customTest.background = theme
        } label: {
            Text(title)
                .font(.title3)
                .fontWeight(isSelected ? .semibold : .regular)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
        }
        .buttonStyle(.bordered)
        .tint(isSelected ? Color.accentColor : Color.secondary)
        .accessibilityLabel(title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    @ViewBuilder
    private func positioningButton(_ positioning: CustomTest.Positioning, title: String) -> some View {
        let isSelected = customTest.positioning == positioning
        Button {
            customTest.positioning = positioning
        } label: {
            Text(title)
                .font(.title3)
                .fontWeight(isSelected ? .semibold : .regular)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
        }
        .buttonStyle(.bordered)
        .tint(isSelected ? Color.accentColor : Color.secondary)
        .accessibilityLabel(title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
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

#if DEBUG
/// Approximates the clinician begin screen for Canvas (no `Scene` / window APIs).
private struct ClinicianBeginPreview: View {
    var body: some View {
        VStack(spacing: ReSoundLayout.sectionSpacing) {
            Text("Hearing Test Customisation")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            Text("No saved tests yet.")
                .font(.body)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, minHeight: 120, alignment: .center)
                .padding(ReSoundLayout.cardPadding)
                .background(
                    RoundedRectangle(cornerRadius: ReSoundLayout.cardCornerRadius)
                        .fill(.ultraThinMaterial)
                )
            Label("Back", systemImage: "chevron.backward")
                .font(.body)
                .fontWeight(.medium)
        }
        .padding(ReSoundLayout.cardPadding)
    }
}

#Preview("Clinician — begin (empty)") {
    ClinicianBeginPreview()
}
#endif
