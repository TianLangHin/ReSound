//
//  HearingTest.swift
//  ReSound
//
//  Created by Tian Lang Hin on 16/3/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

import Foundation

/// This structure assumes a hearing test has a name of its own,
/// a list of audio sources which are customised,
/// and an ordered list of audio sources to be highlighted in each question.

struct HearingTest {
    var name: String
    var audioSources: [TestAudioSource]
    // The `focusLocations` property tells which audio sources will be focused on
    // during the hearing test (and the order in which that happens).
    var focusLocations: [UUID]
    // For now, the background of a hearing test is assumed to be an image.
    var backgroundResourceLink: String

    /// After any adjustment to the hearing test, this will ensure that all
    /// references to audio sources are valid and do not crash the program.
    mutating func fixFocusLocations() {
        self.focusLocations = self.focusLocations.filter({ audioSourceID in
            return audioSources.contains(where: { $0.id == audioSourceID })
        })
    }
}

/// Each audio source in a hearing test environment is uniquely identifiable,
/// has a particular 3D location, and is associated with an asset for representing it visually.
struct TestAudioSource: Identifiable {
    let id = UUID()
    var location: SIMD3<Float>
    var visualResourceLink: VisualResourceType

    enum VisualResourceType {
        case presetBox
        case asset(String)
    }
}

/// This represents a particular question about a certain audio clip,
/// the corresponding multiple choice answers for the question, and the correct answer.
/// Multiple `AudioQuestion` instances can exist for a single audio clip,
/// allowing the creation of more than one question for one reusable piece of audio.
/// It also provides the specification of a duration so an entire clip does not have to be used.
struct AudioQuestion: Equatable {
    let audioResourceLink: String
    let question: String
    let answers: [String]
    let correctAnswer: Int
    let duration: Duration
}
