//
//  InstructionScene.swift
//  ReSound
//
//  Created by Dương Anh Trần on 25/4/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

import SwiftUI

struct InstructionScene: Scene {
    @Environment(\.openWindow) private var openWindow
    @Binding var instructionOpen: Bool
    
    var body: some Scene {
        WindowGroup(id: "instruction-window") {
            VStack {
                Text("Usage Instructions")
                    .font(.largeTitle)
                    .padding()
                
                Spacer()
                    .frame(height: 20)
                
                ScrollView {
                    Text("In this experience, you will listen to some dialogue, and then answer a question about what you've just heard. Please pay attention and answer to the best of your ability!\n")
                        .font(.body)
                    
                    Text("Before you start, please make sure to configure your AVP audio to a reasonable level using the default hand gestures. You can play the provided calibration audio using the Play button as reference.\n")
                        .font(.body)
                    
                    Text("When the experience starts, the window will temporarily disappear while the audio is playing. You will need to listen to the dialogue spoken by the person indicated by the yellow cone (which is marked above them).\n")
                        .font(.body)
                    
                    Text("When the question comes up, there are 4 possible answers to choose from. You can answer by pinching the buttons or by using speech by saying the correlating number (aka 1 to 4).\n")
                    
                    Text("Between questions, you will be prompted to continue to the next question. You can say 'continue' or 'next' to advance. After the experience has concluded, you can say 'exit' or 'quit' to return to the main menu.\n")
                        .font(.body)
                }
                .multilineTextAlignment(.center)
                .padding()
            }
            .overlay(alignment: .bottom) {
                Text("This window will automatically close when you start the simulation.")
                    .font(.headline)
                    .padding()
            }
            .padding()
            .onDisappear {
                instructionOpen = false
            }
        }
        .defaultWindowPlacement { content, context in
            if let mainWindow = context.windows.first {
                return WindowPlacement(.trailing(mainWindow))
            }
            return WindowPlacement()
        }
    }
}
