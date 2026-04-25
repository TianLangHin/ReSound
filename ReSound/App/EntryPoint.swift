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

    /// Since the HearingTestScene will always be part of this Scene's body,
    /// we keep track of which one it is referencing through a reference
    /// to the `HearingTest` instance (which can be managed by a Picker).
    @State var hearingTest = Presets.hearingTests[0]
    @State var viewingState: MainMenuState = .main
    @State var selectedOption: Int = -1
    
    @State var instructionOpen: Bool = false

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
            }
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
        ClinicianScene(speechRec: speechRec)
        HistoryScene(speechRec: speechRec)
    }
    
    @ViewBuilder
    private func loadMainMenu() -> some View {
        VStack {
            /// This internal VStack not really necessary but the other screens have this structure because of the ZStack with back button so this just makes the spacing consistent
            VStack {
                Text("ReSound Hearing Test")
                    .font(.largeTitle)
                Text("Test your hearing using spatial audio with the Apple Vision Pro")
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
                    Text("Start Hearing Test")
                        .font(.headline)
                        .frame(maxWidth: 400)
                        .padding(.vertical, 20)
                }
                .padding(10)
                
                Button {
                    transition(from: "main-window", to: "clinician-window")
                } label: {
                    // Go to the clinician view to create customised hearing tests.
                    Text("Clinician View")
                        .font(.headline)
                        .frame(maxWidth: 400)
                        .padding(.vertical, 20)
                }
                .padding(10)
                
                Button {
                    // Go to view history page which is not currently implemented.
                    transition(from: "main-window", to: "history-window")
                } label: {
                    // Persistent storage which stores a list of patient scores and other related details.
                    Text("View History")
                        .font(.headline)
                        .frame(maxWidth: 400)
                        .padding(.vertical, 20)
                }
                .padding(10)
            }
            .padding()
        }
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
            ZStack {
                VStack {
                    Text("Select Environment")
                        .font(.largeTitle)
                    
                    Text("Choose your immersive testing environment")
                        .font(.title)
                        .foregroundStyle(.secondary)
                }
                .padding()
                
                HStack {
                    Button {
                        viewingState = .main
                    } label: {
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
            }
            
            Spacer()
                .frame(height: 20)
            
            /// The user will get to select which hearing test environment
            /// they wish to take (from the presets we have).
            VStack {
                chooseEnvButton(buttonIndex: 0, title: "Home Room")
                chooseEnvButton(buttonIndex: 1, title: "Train Station")
                /// This last one needs to change when the third preset is added to the patient environment selection view. Since we don't have it imported yet, having buttonIndex: 2 results in an Index out of range error. Because of this placeholder logic choosing café will always take the user to train station instead. Change this to chooseEnvButton(buttonIndex: 2, title: "Café")
                chooseEnvButton(buttonIndex: 1, title: "Café")
            }
            .padding()
        }
        .padding()
        .onChange(of: speechRec.speechContent) { _, newContent in
            print("Speech content: \(newContent)")
            voiceComHandler(newContent)
            print("state: \(viewingState)")
        }
    }

    func chooseEnv(index: Int, makeRandom: Bool = false) {
        hearingTest = makeRandom ? Presets.hearingTests[Int.random(in: 0...1)] : Presets.hearingTests[index]
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
            Text(title)
                .font(.headline)
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
            case "patient", "test":
                viewingState = .chooseTest
            case "clinician", "customise":
                transition(from: "main-window", to: "clinician-window")
            case "history":
                transition(from: "main-window", to: "history-window")
            default:
                break
            }
        case .chooseTest:
            switch voiceInput {
            case "home":
                chooseEnv(index: 0)
            case "train":
                chooseEnv(index: 1)
            case "cafe", "café":
                chooseEnv(index: 2, makeRandom: true)
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
}
