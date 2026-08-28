/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The app's main entry point.
*/

import SwiftUI
import RealityKit

enum MainMenuState {
    case main
    case chooseTest
}

@main
struct EntryPoint: App {
    /// State for speech rec
    @State var speechRec = SpeechRec()

    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    @Environment(\.scenePhase) private var scenePhase

    /// Since the HearingTestScene will always be part of this Scene's body,
    /// we keep track of which one it is referencing through a reference
    /// to the `HearingTest` instance (which can be managed by a Picker).
    @State var hearingTest = Presets.hearingTests[0]
    @State var viewingState: MainMenuState = .main
    @State var selectedOption: Int = -1
    
    @State var instructionOpen: Bool = false
    @State private var openAlready: Bool = false

    /// A binded variable to suppress the main window when a new one pops up
    /// i.e., when the hearing test pops up.
    @State var isHearingTestOpened = false

    @State var transitioning = false

    var body: some SwiftUI.Scene {
        WindowGroup(id: "main-window") {
            /// The content of the main menu is displayed if the hearing test is not happening yet.
            if !isHearingTestOpened {
                VStack {
                    switch viewingState {
                    case .main:
                        loadMainMenu()
                    case .chooseTest:
                        chooseHearingTest()
                    }
                }
                .onAppear {
                    openAlready = true
                }
            }
        }
        .defaultWindowPlacement { content, context in
            if let otherWindow = context.windows.first(where: { $0.id == "instruction-window" }) {
                return WindowPlacement(.leading(otherWindow))
            }
            return WindowPlacement()
        }
        /// The hearing test is administered through this scene,
        /// which by default is closed since the main WindowGroup above is loaded first.
        HearingTestScene(
            hearingTest: $hearingTest,
            isOpened: $isHearingTestOpened, isFromClinician: .constant(false),
            speechRec: speechRec,
            instructionOpen: $instructionOpen, hearingTestWindowId: "hearing-test-window",
            parentWindowId: "main-window")
        InstructionScene(instructionOpen: $instructionOpen)
        ClinicianScene(speechRec: speechRec, instructionOpen: $instructionOpen)
        HistoryScene(speechRec: speechRec)
    }

    @State var speechStart: Bool? = nil

    @ViewBuilder
    private func loadMainMenu() -> some View {
        ZStack {
            VStack {
                VStack {
                    Text("ReSound Hearing Experience")
                        .font(.largeTitle)
                        .padding()
                    Text("Challenge your hearing using spatial audio with the Apple Vision Pro")
                        .font(.title)
                        .foregroundStyle(.secondary)
                }
                .padding()
                
                Spacer()
                    .frame(height: 20)
                
                VStack {
                    Button {
                        viewingState = .chooseTest
                    } label: {
                        // Go to environment selection screen.
                        ZStack {
                            Text("Start Experience")
                                .font(.headline)
                            
                            HStack {
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.headline)
                            }
                        }
                        .frame(maxWidth: 400)
                        .padding(.vertical, 20)
                    }
                    .padding(10)
                    
                    Button {
                        transition(from: "main-window", to: "clinician-window")
                    } label: {
                        // Go to the clinician view to create customised hearing tests.
                        ZStack {
                            Text("Customise Environment")
                                .font(.headline)
                            
                            HStack {
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.headline)
                            }
                        }
                        .frame(maxWidth: 400)
                        .padding(.vertical, 20)
                    }
                    .padding(10)
                    
                    Button {
                        transition(from: "main-window", to: "history-window")
                    } label: {
                        // Persistent storage which stores a list of patient scores and other related details.
                        ZStack {
                            Text("History Log")
                                .font(.headline)
                            
                            HStack {
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.headline)
                            }
                        }
                        .frame(maxWidth: 400)
                        .padding(.vertical, 20)
                    }
                    .padding(10)
                }
                .padding()
            }
            /// Full width so `VStack` children stay centered.
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding()
            .task {
                let _ = await speechRec.authoriseRequest()
                try? speechRec.startRec()
            }
            .onChange(of: speechRec.speechContent) { _, newContent in
                print("Speech content: \(newContent)")
                voiceComHandler(newContent)
                print("state: \(viewingState)")
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        Task {
                            speechRec.stopRec()
                            var approved = await speechRec.authoriseRequest()
                            try? speechRec.startRec()
                            try? await Task.sleep(for: .seconds(2))
                            speechStart = nil

                            speechRec.stopRec()
                            approved = await speechRec.authoriseRequest()
                            try? speechRec.startRec()
                            speechStart = approved
                            print("Speech Reconnection Attempt: \(approved).")
                            try? await Task.sleep(for: .seconds(2))
                            speechStart = nil
                        }
                    } label: {
                        Image(systemName: "microphone.fill")
                            .font(.extraLargeTitle2)
                            .padding()
                        if let speechStart {
                            if speechStart {
                                Image(systemName: "checkmark.circle")
                                    .foregroundStyle(.green)
                            } else {
                                Image(systemName: "x.circle")
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                    .padding(20)
                }
                .padding(20)
            }
            .padding(20)
        }
    }
    
    @ViewBuilder
    private func chooseHearingTest() -> some View {
        VStack {
            VStack {
                Text("Select Environment")
                    .font(.largeTitle)
                Text("Choose your immersive environment")
                    .font(.title)
                    .foregroundStyle(.secondary)
            }
            .padding()
            
            Spacer()
                .frame(height: 20)
            
            /// The user will get to select which hearing test environment
            /// they wish to take (from the presets we have).
            VStack {
                chooseEnvButton(buttonIndex: 0, title: "Home Room")
                chooseEnvButton(buttonIndex: 1, title: "Train Station")
                chooseEnvButton(buttonIndex: 2, title: "Café")
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding()
        .overlay(alignment: .topLeading) {
            backButton {
                viewingState = .main
            }
        }
        .onChange(of: speechRec.speechContent) { _, newContent in
            print("Speech content: \(newContent)")
            voiceComHandler(newContent)
            print("state: \(viewingState)")
        }
    }

    func chooseEnv(index: Int) {
        hearingTest = Presets.hearingTests[index]
        /// An asynchronous task on the main queue is used to load the other window,
        /// wait for 100 milliseconds to ensure the system can recognise it is open,
        /// and then close the previous window (which is only successful if another window is open).
        Task { @MainActor in
            isHearingTestOpened = true
            transition(from: "main-window", to: "hearing-test-window")
            viewingState = .main
            selectedOption = -1
        }
    }

    @ViewBuilder
    private func chooseEnvButton(buttonIndex: Int, title: String) -> some View {
        Button {
            chooseEnv(index: buttonIndex)
        } label: {
            ZStack {
                Text(title)
                    .font(.headline)
                HStack {
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.headline)
                }
            }
            .frame(maxWidth: 400)
            .padding(.vertical, 20)
        }
        .padding(10)
    }

    private func voiceComHandler(_ speech: String) {
        let components = speech.lowercased().components(separatedBy: .whitespaces)
        let previous = components.dropLast().last ?? ""
        let voiceInput = components.last ?? ""

        let mainPrompts = [
            ["start", "experience"],
            ["customise", "customize", "environment"],
            ["history", "log"],
        ]
        let choosePrompts = [
            ["home", "room"],
            ["train", "station"],
            ["cafe", "café"],
        ]
        switch viewingState {
        case .main:
            if mainPrompts[0].contains(voiceInput) && !mainPrompts[0].contains(previous) {
                viewingState = .chooseTest
            } else if mainPrompts[1].contains(voiceInput) && !mainPrompts[1].contains(previous) {
                transition(from: "main-window", to: "clinician-window")
            } else if mainPrompts[2].contains(voiceInput) && !mainPrompts[2].contains(previous) {
                transition(from: "main-window", to: "history-window")
            }
        case .chooseTest:
            for i in 0...2 {
                if choosePrompts[i].contains(voiceInput) && !choosePrompts[i].contains(previous) {
                    chooseEnv(index: i)
                    break
                }
            }
            if voiceInput == "back" {
                viewingState = .main
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
}
