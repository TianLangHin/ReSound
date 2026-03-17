//
//  Presets.swift
//  ReSound
//
//  Created by Tian Lang Hin on 17/3/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

class Presets {
    private static var audioSources: [AudioSource] = [
        AudioSource(type: .ambient, location: .init(x: 0.0, y: 1.0, z: -1.5), visualResourceLink: .presetBox),
        AudioSource(type: .ambient, location: .init(x: 3.0, y: 1.0, z: 0.0), visualResourceLink: .presetBox),
        AudioSource(type: .ambient, location: .init(x: -3.0, y: 1.0, z: 0.0), visualResourceLink: .presetBox),
    ]

    static var hearingTests: [HearingTest] = [
        HearingTest(name: "Preset 1",
                    audioSources: [
                        Presets.audioSources[0],
                        Presets.audioSources[1],
                        Presets.audioSources[2],
                    ],
                    questions: [
                        AudioQuestion(focus: Presets.audioSources[0].id,
                                      chosenQuestion: Presets.possibleQuestions[0],
                                      duration: .seconds(10)),
                        AudioQuestion(focus: Presets.audioSources[1].id,
                                      chosenQuestion: Presets.possibleQuestions[0],
                                      duration: .seconds(10)),
                    ],
                    backgroundResourceLink: "DefaultBackground")
    ]

    static var possibleQuestions: [PossibleQuestion] = [
        PossibleQuestion(audioResourceLink: "Police.mp3",
                         question: "Test Question 1?",
                         answers: [
                            "Incorrect 1",
                            "Incorrect 2",
                            "Correct 3",
                            "Incorrect 4",
                         ],
                         correctAnswer: 2),
    ]

    static var conversationAudioClips: [String] = [
        "Police.mp3",
    ]

    static var ambientAudioClips: [String] = [
        "FunkySynth.m4a",
    ]
}
