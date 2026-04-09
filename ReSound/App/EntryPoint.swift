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
        /// The hearing test is administered through this scene,
        /// which by default is closed since the main WindowGroup above is loaded first.
        HearingTestScene(
            hearingTest: $hearingTest,
            isOpened: $isHearingTestOpened,
            speechRec: speechRec,
            hearingTestWindowId: "hearing-test-window",
            parentWindowId: "main-window")
        ClinicianScene(speechRec: speechRec)
    }
    
    @ViewBuilder
    private func loadMainMenu() -> some View {
        VStack {
            Text("ReSound Hearing Test")
                .font(.system(size: 60))
                .bold()
            Text("Test your hearing using spatial audio with the Apple Vision Pro")
                .font(.system(size: 30))
            
            Spacer()
                .frame(height: 50)
            
            VStack {
                Button {
                    viewingState = .chooseTest
                } label: {
                    // Go to environment selection screen.
                    Text("Start Hearing Test")
                        .font(.system(size: 35))
                        .bold()
                        .frame(maxWidth: 500)
                        .padding(.vertical, 25)
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
                        .font(.system(size: 35))
                        .bold()
                        .frame(maxWidth: 500)
                        .padding(.vertical, 25)
                }
                .padding(10)
                
                Button {
                    // Go to view history page which is not currently implemented.
                } label: {
                    // Persistent storage which stores a list of patient scores and other related details.
                    Text("View History")
                        .font(.system(size: 35))
                        .bold()
                        .frame(maxWidth: 500)
                        .padding(.vertical, 25)
                }
                .padding(10)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(.ultraThinMaterial)
            )
        }
        .padding(.vertical, 25)
        /// Testing for speech recog
        .task {
            let _ = await speechRec.authoriseRequest()
        }
    }
    
    @ViewBuilder
    private func chooseHearingTest() -> some View {
        VStack {
            HStack {
                Button {
                    viewingState = .main
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
            
            Text("Select Environment")
                .font(.system(size: 60))
                .bold()
            
            Text("Choose your immersive testing environment")
                .font(.system(size: 30))
            
            Spacer()
                .frame(height: 50)
            
            /// The user will get to select which hearing test environment
            /// they wish to take (from the presets we have).
            VStack {
                HStack {
                    presetButton(buttonIndex: 0, title: "Home Room")
                    presetButton(buttonIndex: 1, title: "Train Station")
                }
                HStack {
                    presetButton(buttonIndex: 2, title: "Café")
                    presetButton(buttonIndex: 3, title: "Shuffle")
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(.ultraThinMaterial)
            )
            
            Spacer()
                .frame(height: 50)
            
            /// Goes into the patient view (i.e., spawns the hearing test window).
            Button {
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
            } label: {
                HStack {
                    Text("Next")
                        .font(.system(size: 30))
                        .bold()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 30))
                }
                .padding()
            }
            .disabled(selectedOption == -1)
        }
        .padding()
    }
    
    @ViewBuilder
    private func presetButton(buttonIndex: Int, title: String) -> some View {
        Button {
            selectedOption = buttonIndex
            var selectedPreset = buttonIndex
            // If the user chose the third or fourth button (3rd preset or shuffle), make the hearing test load one of the two currently loaded presets. Replace this to > 2 after the third preset is loaded in.
            if selectedPreset > 1 {
                selectedPreset = Int.random(in: 0...1)
            }
            hearingTest = Presets.hearingTests[selectedPreset]
        } label: {
            Text(title)
                .font(.system(size: 35))
                .bold()
                .frame(maxWidth: 500)
                .padding(.vertical, 25)
        }
        .tint(
            selectedOption == buttonIndex ? Color.accentColor : nil
        )
        .padding(10)
    }
}
