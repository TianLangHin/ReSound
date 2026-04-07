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

    /// A binded variable to suppress the main window when the hearing test pops up.
    @State var isHearingTestOpened = false

    var body: some SwiftUI.Scene {
        WindowGroup(id: "main-window") {
            if !isHearingTestOpened {
                VStack {
                    switch viewingState {
                    case .main:
                        MainMenuContentView(
                            viewingState: $viewingState,
                            speechRec: speechRec,
                            onClinicianTap: {
                                Task { @MainActor in
                                    openWindow(id: "clinician-window")
                                    try? await Task.sleep(for: .milliseconds(100))
                                    dismissWindow(id: "main-window")
                                }
                            })
                    case .chooseTest:
                        ChooseEnvironmentView(
                            viewingState: $viewingState,
                            selectedOption: $selectedOption,
                            hearingTest: $hearingTest,
                            onNext: {
                                Task { @MainActor in
                                    isHearingTestOpened = true
                                    openWindow(id: "hearing-test-window")
                                    try? await Task.sleep(for: .milliseconds(100))
                                    dismissWindow(id: "main-window")
                                    viewingState = .main
                                    selectedOption = -1
                                }
                            })
                    }
                }
            }
        }
        HearingTestScene(
            hearingTest: $hearingTest,
            isOpened: $isHearingTestOpened,
            speechRec: speechRec,
            hearingTestWindowId: "hearing-test-window",
            parentWindowId: "main-window")
        ClinicianScene(speechRec: speechRec)
    }
}
