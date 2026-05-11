//
//  HeightAdjustmentScene.swift
//  ReSound
//
//  Created by Tian Lang Hin on 7/5/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

import SwiftUI
import RealityKit

/// Helper Scene containing a window that allows the user to adjust the height of the environment.
struct HeightAdjustmentScene: SwiftUI.Scene {
    @Binding var heightOffset: Float

    let maximum: Float = 1.0
    let minimum: Float = -1.0
    let increment: Float = 0.1

    var body: some SwiftUI.Scene {
        WindowGroup(id: "height-adjustment") {
            VStack {
                Text("Adjust Environment Height")
                    .font(.largeTitle)
                Button {
                    if heightOffset < maximum {
                        heightOffset += increment
                    }
                } label: {
                    ZStack {
                        Text("Move environment up")
                            .font(.headline)
                        HStack {
                            Image(systemName: "chevron.up")
                                .font(.headline)
                            Spacer()
                        }
                    }
                    .frame(width: 400)
                    .padding()
                }
                .disabled(heightOffset >= maximum)
                .buttonRepeatBehavior(.enabled)
                Button {
                    if heightOffset > minimum {
                        heightOffset -= increment
                    }
                } label: {
                    ZStack {
                        Text("Move environment down")
                            .font(.headline)
                        HStack {
                            Image(systemName: "chevron.down")
                                .font(.headline)
                            Spacer()
                        }
                    }
                    .frame(width: 400)
                    .padding()
                }
                .disabled(heightOffset <= minimum)
                .buttonRepeatBehavior(.enabled)
            }
            .padding()
            .glassBackgroundEffect()
        }
        .windowStyle(.plain)
        .defaultWindowPlacement { content, context in
            if let mainWindow = context.windows.first(where: { $0.id != "instruction-window" }) {
                return WindowPlacement(.below(mainWindow))
            }
            return WindowPlacement()
        }
    }
}
