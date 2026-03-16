//
//  Presets.swift
//  ReSound
//
//  Created by Tian Lang Hin on 16/3/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

/// This class defines all the preset resources for hearing tests,
/// audio clips and associated multiple-choice questions.
class Presets {
    /// The `audioSources` variable is private since it exists only as a way
    /// for the instances in `hearingTests` to cotnain the correct UUID values
    /// in the `questionLocations` field, and is not intended for use outside this file.
    private static let audioSources = [
        TestAudioSource(location: .init(x: 0.0, y: 2.0, z: -1.0), visualResourceLink: "Circle"),
        TestAudioSource(location: .init(x: 1.0, y: 2.0, z: -1.0), visualResourceLink: "Circle"),
        TestAudioSource(location: .init(x: -1.0, y: 2.0, z: -1.0), visualResourceLink: "Circle"),
    ]

    /// Will be filled with a set of preset hearing test environments.
    static let hearingTests = [
        HearingTest(name: "Preset 1",
                    audioSources: [
                        audioSources[0],
                        audioSources[1],
                        audioSources[2],
                    ],
                    questionLocations: [
                        audioSources[0].id,
                        audioSources[1].id,
                    ],
                    backgroundResourceLink: "DefaultBackground"),
    ]

    /// Will be filled with the set of all possible questions for any audio source in the project.
    static let audioQuestions = [
        AudioQuestion(audioResourceLink: "FunkySynth.m4a",
                      question: "Test Question 1?",
                      answers: [
                        "Incorrect 1",
                        "Incorrect 2",
                        "Correct 1",
                        "Incorret 3",
                      ],
                      correctAnswer: 2),
    ]
}
