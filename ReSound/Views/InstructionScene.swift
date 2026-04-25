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
                Text("Vstackdunuicnsi")
            }
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
