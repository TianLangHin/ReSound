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
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                dismissWindow(id: "main-window")
                viewingState = .main
                isHearingTestOpened = false
                Task { @MainActor in
                    try? speechRec.startRec()
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
    
    @ViewBuilder
    private func loadMainMenu() -> some View {
        VStack {
            VStack {
                Text("ReSound Hearing Experience")
                    .font(.largeTitle)
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
        /// Testing for speech recog
        .task {
            let _ = await speechRec.authoriseRequest()
            try? speechRec.startRec()
        }
        .onChange(of: speechRec.speechContent) { _, newContent in
            print("Speech content: \(newContent)")
            voiceComHandler(newContent)
            print("state: \(viewingState)")
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
        let voiceInput = speech.lowercased().components(separatedBy: .whitespaces).last ?? ""
        switch viewingState {
        case .main:
            switch voiceInput {
            case "experience", "start":
                viewingState = .chooseTest
            case "customise", "view", "customize", "environment":
                transition(from: "main-window", to: "clinician-window")
            case "history", "log":
                transition(from: "main-window", to: "history-window")
            default:
                break
            }
        case .chooseTest:
            switch voiceInput {
            case "home", "room":
                chooseEnv(index: 0)
            case "train", "station":
                chooseEnv(index: 1)
            case "cafe", "café":
                chooseEnv(index: 2)
            case "back":
                viewingState = .main
            default:
                break
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
