//
//  HearingTest.swift
//  ReSound
//
//  Created by Tian Lang Hin on 17/3/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

import Foundation

/// Every `HearingTest` instance represents a series of questions asked on
/// an environment consisting of a fixed set of audio sources
/// laid around the user's surroundings.
struct HearingTest: Hashable {
    // Each one can be identified by a user-defined name.
    var name: String
    // These `AudioSource` instances are not to be shared with another `HearingTest` instance.
    var audioSources: [AudioSource]
    // Every `AudioQuestion` instance is also not to be shared with another `HearingTest` instance.
    // There are preset question types with pairing audio clips,
    // but those are represented by `PossibleQuestion` instances.
    var questions: [AudioQuestion]
    // For now, the background of a hearing test is assumed to be an image.
    var backgroundResourceLink: String
}

/// The model representing a visual element that emits an audio clip within a hearing test environment.
struct AudioSource: Equatable, Hashable {
    // This `id` attribute allows other structures to easily reference a particular audio source.
    let id = UUID()
    // This will allow customisation by the clinician to adjust the difficulty of the hearing tests.
    // It affects which list of audio files it will take from.
    var type: AudioSourceType
    // Location relative to the user.
    var location: SIMD3<Float>
    // Ideally, this will be an enum of choices between various preset assets.
    var visualResourceLink: VisualResourceType

    enum VisualResourceType: Equatable, Hashable {
        case presetBox
        case asset(String)
    }

    enum AudioSourceType: Equatable, Hashable {
        case conversation(String?)
        case ambient(String?)
        case silent
    }
}

/// This represents a particular instance of a `PossibleQuestion` being applied to a `HearingTest`.
/// This carries the specific information about a question directly applicable to a specific hearing test,
/// with the "template" information being available via `chosenQuestion` instead.
struct AudioQuestion: Equatable, Hashable {
    let focus: UUID
    let chosenQuestion: PossibleQuestion
    // Relative audio level indicating how much to decrease the target audio volume by (compared to original).
    // This is measured in a decibel range from negative infinity to zero (nominal),
    // and thus cannot make an audio louder than the original.
    var volumeLevel: Double = 0.0
}

/// This is the "template" for any `AudioQuestion`.
/// It represents a preset question with a set of answers (and the correct one) referring to a particular audio file.
/// There can be multiple possible questions for one audio file, hence there is no uniqueness constraint on
/// the `audioResourceLink` property.
struct PossibleQuestion: Equatable, Hashable {
    let audioResourceLink: String
    let question: String
    let answers: [String]
    let correctAnswer: Int
    let duration: Duration
}

