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
                    /// The user will get to select which hearing test environment
                    /// they wish to take (from the presets we have).
                    Picker(selection: $hearingTest) {
                        ForEach(Presets.hearingTests, id: \.self) { item in
                            Text(item.name)
                                .tag(item)
                        }
                    } label: {
                        Text("Select test environment.")
                            .font(.title2)
                    }
                    .pickerStyle(.automatic)
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
                        }
                    } label: {
                        Text("Patient View")
                            .font(.title3)
                    }
                    .padding()
                }
                /// Testing for speech recog
                .task {
                    await speechRec.authoriseRequest()
                }
            } else {
                
            }
        }
        /// The hearing test is administered through this scene,
        /// which by default is closed since the main WindowGroup above is loaded first.
        HearingTestScene(hearingTest: $hearingTest, isOpened: $isHearingTestOpened, speechRec: speechRec)
    }
}
