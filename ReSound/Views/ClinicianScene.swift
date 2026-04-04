//
//  ClinicianScene.swift
//  ReSound
//
//  Created by Tian Lang Hin on 4/4/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

import SwiftUI

enum ClinicianState {
    case begin
    case edit(Int)
    case add
}

struct ClinicianScene: Scene {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    @State var clinicianState: ClinicianState = .begin

    @State var isHearingTestOpened = false

    var body: some Scene {
        WindowGroup(id: "clinician-window") {
            VStack {
                switch clinicianState {
                case .begin:
                    beginView()
                case .edit:
                    updateView()
                case .add:
                    updateView()
                }
            }
        }
    }

    @ViewBuilder
    private func beginView() -> some View {
        
    }

    @ViewBuilder
    private func updateView() -> some View {
        
    }

    @MainActor
    private func transitionToPracticeTest(from: String, to: String) {
        Task { @MainActor in
            openWindow(id: from)
            try? await Task.sleep(for: .milliseconds(100))
            dismissWindow(id: to)
        }
    }
}
