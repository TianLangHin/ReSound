/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The app's main entry point.
*/

import SwiftUI
import RealityKit

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
    @State var selectedOption: Int = -1

    /// A binded variable to suppress the main window when a new one pops up
    /// i.e., when the hearing test pops up.
    @State var isHearingTestOpened = false

    var body: some SwiftUI.Scene {
        WindowGroup(id: "main-window") {
            /// The content of the main menu is displayed if the hearing test is not happening yet.
            if !isHearingTestOpened {
                VStack {
                    Text("ReSound Hearing Test")
                        .font(.system(size: 60))
                        .bold()
                    Text("Test your hearing using spatial audio with the Apple Vision Pro")
                        .font(.system(size: 25))
                    
                    VStack {
                        Button {
                            isHearingTestOpened = true
                        } label: {
                            // Goes to the patient view.
                            Text("Start Hearing Test")
                                .font(.title3)
                        }
                        
                        Button {
                            // Clinician view not currently implemented.
                        } label: {
                            // Customising test suites.
                            Text("Clinician View")
                                .font(.title3)
                        }
                        
                        Button {
                            // Go to view history page which is not currently implemented.
                        } label: {
                            // Persistent storage which stores a list of patient scores and other related details.
                            Text("View History")
                                .font(.title3)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.ultraThinMaterial)
                    )
                }
                /// Testing for speech recog
                .task {
                    await speechRec.authoriseRequest()
                }
            } else {
                chooseHearingTest()
            }
        }
        /// The hearing test is administered through this scene,
        /// which by default is closed since the main WindowGroup above is loaded first.
        HearingTestScene(hearingTest: $hearingTest, isOpened: $isHearingTestOpened, speechRec: speechRec)
    }
    
    @ViewBuilder
    private func chooseHearingTest() -> some View {
        VStack {
            HStack {
                Button {
                    isHearingTestOpened = false
                } label: {
                    Image(systemName: "chevron.left")
                }
                Spacer()
            }
            
            Text("Select Environment")
                .font(.system(size: 60))
                .bold()
            
            Text("Choose your immersive testing environment")
                .font(.system(size: 25))
            
            /// The user will get to select which hearing test environment
            /// they wish to take (from the presets we have).
            VStack {
                HStack {
                    presetButton(buttonIndex: 0, title: "TEST")
                    presetButton(buttonIndex: 1, title: "Train Station")
                }
                HStack {
                    presetButton(buttonIndex: 2, title: "Do Not Use")
                    presetButton(buttonIndex: 3, title: "Shuffle")
                }
            }
            .padding()

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
                    selectedOption = -1
                }
            } label: {
                Text("Next")
                    .font(.title3)
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
                .font(.title3)
        }
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(selectedOption == buttonIndex ? Color.green : Color.clear)
        )
    }
}
