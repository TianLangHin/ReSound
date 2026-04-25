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
    
    private let optionControlWidth: CGFloat = 350
    private let optionCardSpacing: CGFloat = 16
    private let editorSectionSpacing: CGFloat = 16
    
    private let optionCardInnerPadding: CGFloat = 16

    private let actionButtonWidth: CGFloat = 160
    private let actionButtonHeight: CGFloat = 72

    private var editorGroupWidth: CGFloat {
        ((optionControlWidth + (optionCardInnerPadding * 2)) * 2) + optionCardSpacing
    }

    private var environmentSelection: Binding<Int> {
        Binding(
            get: {
                switch customTest.background {
                case .home: return 0
                case .cafe: return 1
                case .train: return 2
                }
            },
            set: { value in
                switch value {
                case 0: customTest.background = .home
                case 1: customTest.background = .cafe
                default: customTest.background = .train
                }
            })
    }

    private var difficultySelection: Binding<Int> {
        Binding(
            get: {
                switch customTest.positioning {
                case .easy: return 0
                case .medium: return 1
                case .hard: return 2
                }
            },
            set: { value in
                switch value {
                case 0: customTest.positioning = .easy
                case 1: customTest.positioning = .medium
                default: customTest.positioning = .hard
                }
            })
    }

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
            .onChange(of: speechRec.speechContent) { _, newContent in
                let lastWord = newContent.lowercased().components(separatedBy: .whitespaces).last ?? ""
                if lastWord == "back", case .begin = clinicianState {
                    transition(from: "clinician-window", to: "main-window")
                }
            }
        }
        .defaultWindowPlacement { content, context in
            if let otherWindow = context.windows.first(where: { $0.id != "main-window" }) {
                return WindowPlacement(.above(otherWindow))
            }
            return WindowPlacement()
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
            clinicianBackBar {
                transition(from: "clinician-window", to: "main-window")
            }
            
            /// Put any other title or subtitle text here for clinician view
            VStack {
                Text("Hearing Test Customisation")
                    .font(.system(size: 60))
                    .bold()
                Text("Add or edit your own custom test environment")
                    .font(.system(size: 30))
            }
            .frame(maxWidth: .infinity)
            .padding()
            
            Spacer()
                .frame(height: 20)
            
            VStack {
                if savedCustoms.isEmpty {
                    Text("No saved tests yet.")
                        .font(.system(size: 30))
                        .padding()
                } else {
                    List {
                        ForEach(savedCustoms, id: \.id) { test in
                            Button {
                                if let index = savedCustoms.firstIndex(where: { $0.id == test.id }) {
                                    customTest = savedCustoms[index]
                                    clinicianState = .edit(index)
                                }
                            } label: {
                                HStack {
                                    Text("\(test.name) (ID: \(test.id))")
                                        .font(.system(size: 30))
                                        .bold()
                                        .padding(.vertical, 16)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 30))
                                }
                                .padding()
                            }
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
                    .padding(.horizontal)
                }
            }
            .padding()
            
            Button {
                // Set name for the new test saving because no text field
                customTest = CustomTest()
                customTest.name = "Custom Test \(savedTests.count + 1)"
                clinicianState = .add
            } label: {
                HStack {
                    Text("Add")
                        .font(.system(size: 30))
                        .bold()
                        .padding(.vertical, 2)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 30))
                }
                .padding()
            }
            .tint(Color.accentColor)
            .padding()
        }
        /// Fill the window and pin content to the top; otherwise a short stack can sit lower
        /// than a tall one and the back row appears to “move down” when switching screens.
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
        .onChange(of: speechRec.speechContent) { _, newContent in
            print("Speech content: \(newContent)")
            voiceComHandler(newContent)
            print("state: \(clinicianState)")
        }
    }

    @ViewBuilder
    private func updateView() -> some View {
        VStack(spacing: editorSectionSpacing) {
            clinicianBackBar {
                clinicianState = .begin
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Test Name")
                    .font(.system(size: 28))
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .center)
                
                TextField("Enter test name", text: $customTest.name)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 24))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
            }
            .padding()
            .frame(width: editorGroupWidth, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(.ultraThinMaterial)
            )
            
            HStack(spacing: optionCardSpacing) {
                VStack {
                    Text("Environment")
                        .font(.system(size: 28))
                        .bold()

                    Picker("Environment", selection: environmentSelection) {
                        Text("Home").tag(0)
                        Text("Café").tag(1)
                        Text("Train").tag(2)
                    }
                    .frame(width: optionControlWidth, height: 50, alignment: .leading)
                    .pickerStyle(.segmented)
                    .padding(.top, 16)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(.ultraThinMaterial)
                )
                
                VStack {
                    Text("Difficulty")
                        .font(.system(size: 28))
                        .bold()

                    Picker("Difficulty", selection: difficultySelection) {
                        Text("Easy").tag(0)
                        Text("Medium").tag(1)
                        Text("Hard").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: optionControlWidth, height: 50, alignment: .leading)
                    .padding(.top, 16)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(.ultraThinMaterial)
                )
            }
            .frame(width: editorGroupWidth)
            
            HStack(spacing: optionCardSpacing) {
                VStack {
                    Text("Number of Questions")
                        .font(.system(size: 28))
                        .bold()
                    
                     Stepper(value: $customTest.numberOfQuestions, in: 1...5, step: 1) {
                        Text("Questions: \(customTest.numberOfQuestions)")
                            .font(.system(size: 25))
                            .bold()
                    }
                    .frame(width: optionControlWidth, height: 50, alignment: .leading)
                    .tint(.accentColor)
                    .padding(.top, 16)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(.ultraThinMaterial)
                )
                
                VStack {
                    Text("Volume")
                        .font(.system(size: 28))
                        .bold()
                    
                    Slider(value: $customTest.targetVolume, in: -10.0 ... 0)
                        .frame(width: optionControlWidth, height: 50, alignment: .leading)
                        .padding(.top, 16)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(.ultraThinMaterial)
                )
            }
            .frame(width: editorGroupWidth)
            
            HStack (spacing: 16) {
                Button {
                    hearingTest = customTest.generateTest()
                    isHearingTestOpened = true
                    transition(from: "clinician-window", to: "practice-window")
                } label: {
                    Text("Practice")
                        .font(.system(size: 28))
                        .bold()
                        .frame(width: actionButtonWidth, height: actionButtonHeight)
                }
                
                // Save Button
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
                    Text("Save")
                        .font(.system(size: 28))
                        .bold()
                        .frame(width: actionButtonWidth, height: actionButtonHeight)
                }
                .tint(Color.green)
            }
            .padding()
        }
        /// Full width so the back row spans the window; full height + top alignment so the
        /// back row matches `beginView` vertically when this screen has less content.
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
        .onChange(of: speechRec.speechContent) { _, newContent in
            print("Speech content: \(newContent)")
            voiceComHandler(newContent)
            print("state: \(clinicianState)")
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
    
    
    private func voiceComHandler(_ speech: String) {
        let voiceInput = speech.lowercased().components(separatedBy: .whitespaces).last ?? ""
        let words = speech.lowercased().components(separatedBy: .whitespaces)
        let numberWords: [String: Int] = [
            "one": 1,
            "two": 2,
            "three": 3,
            "four": 4,
            "five": 5
        ]
        
        switch clinicianState {
        case .begin:
            if voiceInput.contains("add") {
                customTest = CustomTest()
                customTest.name = "Custom Test \(savedTests.count + 1)"
                clinicianState = .add
            }
            if let editIndex = words.lastIndex(of: "number"),
               editIndex + 2 == words.count {
               let nextWord = words[editIndex + 1]
               if let number = numberWords[nextWord], number >= 1 && number <= savedCustoms.count {
                  let index = number - 1
                  customTest = savedCustoms[index]
                  clinicianState = .edit(index)
               }
            }
            
        case .edit(let num):
            if voiceInput.contains("save") {
                savedCustoms[num] = customTest
                PersistStorage.testStorage.saveCustom(savedCustoms)
                clinicianState = .begin
            } else if voiceInput.contains("back") {
                clinicianState = .begin
            } else {
                applyMappedSelection(from: voiceInput)
            }
            if let questionIndex = words.lastIndex(of: "question"),
               questionIndex + 1 < words.count {
                let nextWord = words[questionIndex + 1]
                if let number = numberWords[nextWord], number >= 1 && number <= 5 {
                    customTest.numberOfQuestions = number
                }
            }

        case .add:
            if voiceInput.contains("save") {
                let test = customTest.generateTest()
                savedCustoms.append(customTest)
                savedTests.append(test)
                PersistStorage.testStorage.saveCustom(savedCustoms)
                PersistStorage.testStorage.saveTest(savedTests)
                clinicianState = .begin
            } else if voiceInput.contains("back") {
                clinicianState = .begin
            } else {
                applyMappedSelection(from: voiceInput)
            }
            if let questionIndex = words.lastIndex(of: "question"),
               questionIndex + 1 < words.count {
                let nextWord = words[questionIndex + 1]
                if let number = numberWords[nextWord], number >= 1 && number <= 5 {
                    customTest.numberOfQuestions = number
                }
            }
        }
    }

    private func applyMappedSelection(from voiceInput: String) {
        if let background = mappedBackground(from: voiceInput) {
            customTest.background = background
            return
        }
        if let positioning = mappedPositioning(from: voiceInput) {
            customTest.positioning = positioning
        }
    }

    private func mappedBackground(from voiceInput: String) -> CustomTest.Theme? {
        if voiceInput.contains("home") {
            return .home
        }
        if voiceInput.contains("train") {
            return .train
        }
        if voiceInput.contains("cafe") || voiceInput.contains("café") {
            return .cafe
        }
        return nil
    }

    private func mappedPositioning(from voiceInput: String) -> CustomTest.Positioning? {
        if voiceInput.contains("easy") {
            return .easy
        }
        if voiceInput.contains("medium") {
            return .medium
        }
        if voiceInput.contains("hard") {
            return .hard
        }
        return nil
    }
    
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
    
    /// Shared back bar for `beginView` and `updateView` (same width, padding, alignment).
    @ViewBuilder
    private func clinicianBackBar(action: @escaping () -> Void) -> some View {
        HStack(spacing: 0) {
            backButton(action: action)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 20)
        .padding(.top, 20)
    }
    
}
