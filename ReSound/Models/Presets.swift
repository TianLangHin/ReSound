//
//  Presets.swift
//  ReSound
//
//  Created by Tian Lang Hin on 17/3/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

class Presets {
    private static var audioSources: [AudioSource] = [
        AudioSource(
            type: .ambient(nil),
            location: .init(x: 0.0, y: 1.0, z: -1.5),
            visualResourceLink: .asset("BluePeakCharacter.usdz")),
        AudioSource(
            type: .ambient(nil),
            location: .init(x: 3.0, y: 1.0, z: 0.0),
            visualResourceLink: .presetBox),
        AudioSource(
            type: .ambient(nil),
            location: .init(x: -3.0, y: 1.0, z: 0.0),
            visualResourceLink: .presetBox),
        AudioSource(
            type: .conversation("AudioSample1.mp3"),
            location: .init(x: 0.0, y: 1.0, z: -1.5),
            visualResourceLink: .asset("BluePeakCharacter.usdz")),
        AudioSource(
            type: .ambient("Train_Departing.mp3"),
            location: .init(x: -3.0, y: 1.5, z: -0.5),
            visualResourceLink: .presetBox),
        AudioSource(
            type: .ambient("Train_PeopleTalking.mp3"),
            location: .init(x: 1.5, y: 1.5, z: -0.5),
            visualResourceLink: .asset("BluePeakCharacter.usdz")),
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
                                      chosenQuestion: Presets.possibleQuestions[1],
                                      duration: .seconds(10)),
                    ],
                    backgroundResourceLink: "blue_photo_studio_4k.hdr"),
        HearingTest(name: "Train Station",
                    audioSources: [
                        Presets.audioSources[3],
                        Presets.audioSources[4],
                        Presets.audioSources[5],
                    ],
                    questions: [
                        AudioQuestion(focus: Presets.audioSources[3].id,
                                      chosenQuestion: Presets.possibleQuestions[2],
                                      duration: .seconds(30)),
                        AudioQuestion(focus: Presets.audioSources[5].id,
                                      chosenQuestion: Presets.possibleQuestions[3],
                                      duration: .seconds(30)),
                    ],
                    backgroundResourceLink: "dresden_station_night_4k.exr"),
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
        PossibleQuestion(audioResourceLink: "Police.mp3",
                         question: "Test Question 2?",
                         answers: [
                            "Correct 1",
                            "Incorrect 2",
                            "Incorrect 3",
                            "Incorrect 4"
                         ],
                         correctAnswer: 0),
        /// Created by Yu-Han Chang on 22 March.
        PossibleQuestion(audioResourceLink: "Train_Announcement.mp3",
                         question: "Which platform will the next train arrive on?",
                         answers: [
                            "Platform 21",
                            "Platform 33",
                            "Platform 23",
                            "Platform 22"
                         ],
                         correctAnswer: 2),
        PossibleQuestion(audioResourceLink: "Train_Announcement.mp3",
                         question: "Which is the first stop of this train going to Macarthur?",
                         answers: [
                            "Mascot",
                            "Green Square",
                            "Domestic Airport",
                            "International Airport"
                         ],
                         correctAnswer: 1),
        PossibleQuestion(audioResourceLink: "Train_Announcement.mp3",
                         question: "Which Airport stop will come first for this train going to Macarthur?",
                         answers: [
                            "Domestic Airport",
                            "International Airport",
                            "Sydney Airport",
                            "None of them"
                         ],
                         correctAnswer: 1),
    ]

    static var conversationAudioClips: [String] = [
        "Police.mp3",
        "AudioSample1.mp3",
        "AudioSample2.mp3",
        "Train_Announcement.mp3",
        "Home_WeatherForecast.mp3",
    ]

    static var ambientAudioClips: [String] = [
        "FunkySynth.m4a",
        "Cafe_Ambience.mp3",
        "Cafe_Music.mp3",
        "Train_Birds.mp3",
        "Train_Departing.mp3",
        "Train_PeopleTalking.mp3",
    ]
}
