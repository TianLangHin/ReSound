/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The app's main entry point.
*/

import SwiftUI

@main
struct EntryPoint: App {
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    @State var question: AudioQuestion? = nil

    var body: some Scene {
        WindowGroup {
            HStack {
                Button("Open") {
                    Task {
                        await openImmersiveSpace(id: "test1")
                    }
                }
                Button("Close") {
                    Task {
                        await dismissImmersiveSpace()
                    }
                }
                Button("Start Question") {
                    question = Presets.audioQuestions[0]
                }
                Button("Stop Question") {
                    question = nil
                }
            }
        }
        ImmersiveSpace(id: "test1") {
            let hearingTest = Presets.hearingTests[0]
            // TestAudioSource is Identifiable.
            ForEach(hearingTest.audioSources) { source in
                SpatialAudioView(
                    testAudioSource: source,
                    isFocused: .constant(source.id == hearingTest.focusLocations[0]),
                    question: $question)
            }
        }
        .immersionStyle(selection: .constant(.full), in: .full)
    }
}
