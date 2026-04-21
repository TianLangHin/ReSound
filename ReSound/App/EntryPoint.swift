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
        .defaultWindowPlacement { content, context in
            if let otherWindow = context.windows.first(where: { $0.id != "clinician-window" && $0.id != "history-window" }) {
                return WindowPlacement(.above(otherWindow))
            }
            return WindowPlacement()
        }
        /// The hearing test is administered through this scene,
        /// which by default is closed since the main WindowGroup above is loaded first.
        HearingTestScene(
            hearingTest: $hearingTest,
            isOpened: $isHearingTestOpened,
            speechRec: speechRec,
            hearingTestWindowId: "hearing-test-window",
            parentWindowId: "main-window")
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
                    Task { @MainActor in
                        openWindow(id: "clinician-window")
                        try? await Task.sleep(for: .milliseconds(100))
                        dismissWindow(id: "main-window")
                    }
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
                    Task { @MainActor in
                        openWindow(id: "history-window")
                        try? await Task.sleep(for: .milliseconds(100))
                        dismissWindow(id: "main-window")
                    }
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
            openWindow(id: "hearing-test-window")
            try? await Task.sleep(for: .milliseconds(100))
            dismissWindow(id: "main-window")
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
            if voiceInput.contains("patient") || voiceInput.contains("test") {
                viewingState = .chooseTest
            } else if voiceInput.contains("clinician") || voiceInput.contains("customise") {
                Task { @MainActor in
                    openWindow(id: "clinician-window")
                    try? await Task.sleep(for: .milliseconds(100))
                    dismissWindow(id: "main-window")
                }
            } else if voiceInput.contains("history") {
                Task { @MainActor in
                    openWindow(id: "history-window")
                    try? await Task.sleep(for: .milliseconds(100))
                    dismissWindow(id: "main-window")
                }
            }
            
        case .chooseTest:
            if voiceInput.contains("home") || voiceInput.contains("one") {
                chooseEnv(index: 0)
            } else if voiceInput.contains("train") || voiceInput.contains("two") {
                chooseEnv(index: 1)
            } else if voiceInput.contains("cafe") || voiceInput.contains("café") || voiceInput.contains("three") {
                chooseEnv(index: 2, makeRandom: true)
            } else if voiceInput.contains("shuffle") || voiceInput.contains("four") {
                chooseEnv(index: 3, makeRandom: true)
            } else if voiceInput.contains("next") || voiceInput.contains("start") {
                guard selectedOption != -1 else { return }
                Task { @MainActor in
                    isHearingTestOpened = true
                    openWindow(id: "hearing-test-window")
                    try? await Task.sleep(for: .milliseconds(100))
                    dismissWindow(id: "main-window")
                    viewingState = .main
                    selectedOption = -1
                }
            } else if voiceInput.contains("back") {
                viewingState = .main
            }
        }
    }
}




