//
//  ClinicianScene.swift
//  ReSound
//
//  Created by Tian Lang Hin on 4/4/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

import SwiftUI
//Note: after practice the spedech rec is closed, will have to reactivate again
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
    
    // Slow down the process of recognising speech
    @State private var numberDebounceTask: Task<Void, Never>? = nil
    
    @State var isFromClinician = false

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
            .onAppear {
                if !isFromClinician {
                    clinicianState = .begin
                }
            }
        }
        HearingTestScene(
            hearingTest: $hearingTest,
            isOpened: $isHearingTestOpened,
            isFromClinician: $isFromClinician,
            speechRec: speechRec,
            instructionOpen: .constant(false), hearingTestWindowId: "practice-window",
            parentWindowId: "clinician-window")
    }

    @ViewBuilder
    private func beginView() -> some View {
        VStack {
            ZStack {
                /// Put any other title or subtitle text here for clinician view
                VStack {
                    Text("Hearing Test Customisation")
                        .font(.system(size: 60))
                        .bold()
                    Text("Add or edit your own custom test environment")
                        .font(.system(size: 30))
                }
                .padding()
                
                HStack {
                    Button {
                        transition(from: "clinician-window", to: "main-window")
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
                                        .padding(.vertical, 10)
                                    
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
        .padding()
        .onChange(of: speechRec.speechContent) { _, newContent in
            print("Speech content: \(newContent)")
            voiceComHandler(newContent)
            Task {
                try? await Task.sleep(for: .milliseconds(800))
                print("state: \(clinicianState)")
            }
        }
    }

    @ViewBuilder
    private func updateView() -> some View {
        VStack {
            HStack {
                Button {
                    clinicianState = .begin
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
            
            HStack {
                VStack {
                    Text("Environment")
                        .font(.system(size: 40))
                        .bold()
                    
                    Button {
                        customTest.background = .home
                    } label: {
                        Text("Home")
                            .font(.system(size: 35))
                            .bold()
                            .frame(maxWidth: 250)
                            .padding(.vertical, 25)
                    }
                    .tint(customTest.background == .home ? Color.accentColor : nil)
                    .padding(5)
                    
                    Button {
                        customTest.background = .cafe
                    } label: {
                        Text("Café")
                            .font(.system(size: 35))
                            .bold()
                            .frame(maxWidth: 250)
                            .padding(.vertical, 25)
                    }
                    .tint(customTest.background == .cafe ? Color.accentColor : nil)
                    .padding(5)
                    
                    Button {
                        customTest.background = .train
                    } label: {
                        Text("Train Station")
                            .font(.system(size: 35))
                            .bold()
                            .frame(maxWidth: 250)
                            .padding(.vertical, 25)
                    }
                    .tint(customTest.background == .train ? Color.accentColor : nil)
                    .padding(5)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(.ultraThinMaterial)
                )
                
                VStack {
                    Text("Difficulty")
                        .font(.system(size: 40))
                        .bold()
                    
                    Button {
                        customTest.positioning = .easy
                    } label: {
                        Text("Easy")
                            .font(.system(size: 35))
                            .bold()
                            .frame(maxWidth: 250)
                            .padding(.vertical, 25)
                    }
                    .tint(customTest.positioning == .easy ? Color.accentColor : nil)
                    .padding(5)
                    
                    Button {
                        customTest.positioning = .medium
                    } label: {
                        Text("Medium")
                            .font(.system(size: 35))
                            .bold()
                            .frame(maxWidth: 250)
                            .padding(.vertical, 25)
                    }
                    .tint(customTest.positioning == .medium ? Color.accentColor : nil)
                    .padding(5)
                    
                    Button {
                        customTest.positioning = .hard
                    } label: {
                        Text("Hard")
                            .font(.system(size: 35))
                            .bold()
                            .frame(maxWidth: 250)
                            .padding(.vertical, 25)
                    }
                    .tint(customTest.positioning == .hard ? Color.accentColor : nil)
                    .padding(5)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(.ultraThinMaterial)
                )
                
                VStack {
                    Text("Other")
                        .font(.system(size: 40))
                        .bold()
                    
                    HStack {
                        Text("Volume")
                            .font(.system(size: 25))
                            .bold()
                        
                        Slider(value: $customTest.targetVolume, in: -10.0 ... 0)
                            .frame(width: 200)
                            .padding()
                    }
                    .padding()
                    
                    Stepper("Questions: \(customTest.numberOfQuestions)",
                        value: $customTest.numberOfQuestions, in: 1...5, step: 1)
                        .frame(width: 250)
                        .font(.system(size: 25))
                        .bold()
                        .padding()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(.ultraThinMaterial)
                )
            }
            HStack {
                Button {
                    hearingTest = customTest.generateTest()
                    isHearingTestOpened = true
                    transition(from: "clinician-window", to: "practice-window")
                } label: {
                    Text("Practice")
                        .font(.system(size: 30))
                        .bold()
                        .padding()
                }
                
                // Save Button here
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
                        .font(.system(size: 30))
                        .bold()
                        .padding()
                }
                .tint(Color.green)
            }
            .padding()
        }
        .padding()
        .onChange(of: speechRec.speechContent) { _, newContent in
            print("Speech content: \(newContent)")
            voiceComHandler(newContent)
            Task {
                try? await Task.sleep(for: .milliseconds(800))
                print("state: \(clinicianState)")
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
    
    
    private func voiceComHandler(_ speech: String) {
        let voiceInput = speech.lowercased().components(separatedBy: .whitespaces).last ?? ""
        let words = speech.lowercased().components(separatedBy: .whitespaces)

        switch clinicianState {
        case .begin:
            if voiceInput.contains("add") {
                customTest = CustomTest()
                customTest.name = "Custom Test \(savedTests.count + 1)"
                clinicianState = .add
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
                              case .begin = clinicianState else { return }
                        
                        let latestRemaining = Array(latestWords[(latestNumberIndex + 1)...])
                        if let number = parseSpokenNumber(latestRemaining),
                           number >= 1 && number <= savedCustoms.count {
                            let index = number - 1
                            customTest = savedCustoms[index]
                            clinicianState = .edit(index)
                        }
                    }
                }
            }

        case .edit(let num):
            voiceOptions(voiceInput)
            if voiceInput.contains("save") {
                savedCustoms[num] = customTest
                PersistStorage.testStorage.saveCustom(savedCustoms)
                clinicianState = .begin
            }
            if let questionIndex = words.lastIndex(of: "question"),
               questionIndex + 1 < words.count {
                let remainingWords = Array(words[(questionIndex + 1)...])
                if let number = parseSpokenNumber(remainingWords),
                   number >= 1 && number <= 5 {
                    customTest.numberOfQuestions = number
                }
            }

        case .add:
            voiceOptions(voiceInput)
            if voiceInput.contains("save") {
                let test = customTest.generateTest()
                savedCustoms.append(customTest)
                savedTests.append(test)
                PersistStorage.testStorage.saveCustom(savedCustoms)
                PersistStorage.testStorage.saveTest(savedTests)
                clinicianState = .begin
            }
            if let questionIndex = words.lastIndex(of: "question"),
               questionIndex + 1 < words.count {
                let remainingWords = Array(words[(questionIndex + 1)...])
                if let number = parseSpokenNumber(remainingWords),
                   number >= 1 && number <= 5 {
                    customTest.numberOfQuestions = number
                }
            }
        }
    }
    
    private func voiceOptions(_ voiceInput: String) {
        if voiceInput.contains("home") {
            customTest.background = .home
        } else if voiceInput.contains("train") {
            customTest.background = .train
        } else if voiceInput.contains("cafe") || voiceInput.contains("café") {
            customTest.background = .cafe
        } else if voiceInput.contains("easy") {
            customTest.positioning = .easy
        } else if voiceInput.contains("medium") {
            customTest.positioning = .medium
        } else if voiceInput.contains("hard") {
            customTest.positioning = .hard
        } else if voiceInput.contains("back") {
            clinicianState = .begin
        } else if voiceInput.contains("practice") {
            hearingTest = customTest.generateTest()
            isHearingTestOpened = true
            transition(from: "clinician-window", to: "practice-window")
        }
    }
}
