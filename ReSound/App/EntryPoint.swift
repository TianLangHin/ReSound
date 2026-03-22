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

    @State var hearingTest = Presets.hearingTests[0]
    @State var hearingTestNumber = 0
    @State var isHearingTestOpened = false

    var body: some SwiftUI.Scene {
        WindowGroup(id: "main-window") {
            if !isHearingTestOpened {
                VStack {
                    Picker(selection: $hearingTest) {
                        ForEach(Presets.hearingTests, id: \.self) { item in
                            Text(item.name)
                                .font(.title2)
                                .padding()
                                .tag(item)
                        }
                    } label: {
                        Text("Select test environment.")
                            .font(.title2)
                    }
                    .padding()
                    Button {
                        isHearingTestOpened = true
                        openWindow(id: "hearing-test-window")
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
            }
        }
        HearingTestScene(hearingTest: $hearingTest, isOpened: $isHearingTestOpened, speechRec: speechRec)
    }
}
