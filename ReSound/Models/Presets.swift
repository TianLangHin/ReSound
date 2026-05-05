//
//  Presets.swift
//  ReSound
//
//  Created by Tian Lang Hin on 17/3/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

import RealityKit

class Presets {
    private static var audioSources: [AudioSource] = [
        // Home resources.
        AudioSource(
            type: .silent,
            location: .init(x: 0.15, y: 0.40, z: -2.1),
            visualResourceLink: .video("weather-intro")),
        AudioSource(type: .ambient("Home_People Talking.mp3"),
            location: .init(x: 1.6, y: 0.10, z: 1.2),
            visualResourceLink: .animated("ANIM_StandingWoman1.usdz"),
            orientation: simd_quatf(angle: -.pi/2, axis: [0, 1, 0])),
        AudioSource(type: .silent,
            location: .init(x: 0.4, y: 0.25, z: 1.1),
            visualResourceLink: .animated("ANIM_SittingWoman1.usdz"),
            orientation: simd_quatf(angle: .pi, axis: [0, 1, 0])),
        // Train resources.
        AudioSource(
            type: .silent,
            location: .init(x: 0.8, y: 0.4, z: -2.5),
            visualResourceLink: .asset("Train_Loudspeaker.usdz"),
            orientation: simd_quatf(angle: -.pi / 2, axis: [0, 1, 0])),
        AudioSource(
            type: .conversation("AudioSample2.mp3"),
            location: .init(x: 1.5, y: 0.0, z: -0.7),
            visualResourceLink: .animated("ANIM_StandingMan1.usdz"),
            orientation: simd_quatf(angle: .zero, axis: [0, 1, 0])),
        AudioSource(
            type: .silent,
            location: .init(x: 0.8, y: 0.6, z: 1.5),
            visualResourceLink: .asset("Train_Loudspeaker.usdz"),
            orientation: simd_quatf(angle: -.pi / 2, axis: [0, 1, 0])),
        // Cafe resources.
        AudioSource(
            type: .silent,
            location: .init(x: -0.5, y: -0.3, z: -2.8),
            visualResourceLink: .animated("ANIM_StandingWoman4.usdz")),
        AudioSource(
            type: .silent,
            location: .init(x: 0.5, y: -0.15, z: -2.8),
            visualResourceLink: .animated("ANIM_StandingWoman2.usdz")),
        AudioSource(
            type: .ambient("Cafe_Ambience.mp3"),
            location: .init(x: 3.0, y: 0.0, z: 2.0),
            visualResourceLink: .asset("")),
        AudioSource(
            type: .ambient("Cafe_Music.mp3"),
            location: .init(x: 0.0, y: 5.0, z: 0.0),
            visualResourceLink: .asset("")),
        // More home resources.
        AudioSource(
            type: .ambient("Train_Departing.mp3"),
            location: .init(x: 0.0, y: 0.4, z: 0.0),
            visualResourceLink: .animated("TrainCarriage_Resized.usdz")),
        AudioSource(
            type: .ambient("Train_Departing.mp3"),
            location: .init(x: 0.0, y: 0.6, z: 13.0),
            visualResourceLink: .animated("TrainCarriage_Resized.usdz")),
        AudioSource(
            type: .ambient("Train_Departing.mp3"),
            location: .init(x: 0.0, y: 0.7, z: -13.0),
            visualResourceLink: .animated("TrainCarriage_Resized.usdz")),
    ]

    static var hearingTests: [HearingTest] = [
        HearingTest(name: "Home",
                    audioSources: [
                        Presets.audioSources[0],
                        Presets.audioSources[1],
                        Presets.audioSources[2],
                        AudioSource(
                            type: .ambient("Home_CatSound.mp3"),
                            location: .init(x: -2.0, y: 0.3, z: -0.5),
                            visualResourceLink: .asset("Home_Cat.usdz")),
                        AudioSource(type: .ambient("Home_CarPassing.mp3"),
                            location: .init(x: 5.0, y: 0.0, z: 0.0),
                            visualResourceLink: .asset("")),
                    ],
                    questions: [
                        AudioQuestion(focus: Presets.audioSources[0].id,
                                      chosenQuestion: Presets.possibleQuestions[5]),
                        AudioQuestion(focus: Presets.audioSources[0].id,
                                      chosenQuestion: Presets.possibleQuestions[6]),
                        AudioQuestion(focus: Presets.audioSources[0].id,
                                      chosenQuestion: Presets.possibleQuestions[7]),
                    ],
                    backgroundResourceLink: "Home"),
        HearingTest(name: "Train Station",
                    audioSources: [
                        Presets.audioSources[3],
                        Presets.audioSources[4],
                        Presets.audioSources[5],
                        Presets.audioSources[10],
                        Presets.audioSources[11],
                        Presets.audioSources[12],
                        AudioSource(
                            type: .conversation("AudioSample1.mp3"),
                            location: .init(x: 1.5, y: 0.5, z: 0.5),
                            visualResourceLink: .animated("ANIM_StandingMan1.usdz"),
                            orientation: simd_quatf(angle: .pi, axis: [0, 1, 0])),
                        AudioSource(type: .silent,
                            location: .init(x: 0.0, y: 0.6, z: 7.0),
                            visualResourceLink: .asset("Woman3.usdz"),
                            orientation: simd_quatf(angle: .pi, axis: [0, 1, 0])),
                    ],
                    questions: [
                        AudioQuestion(focus: Presets.audioSources[3].id,
                                      chosenQuestion: Presets.possibleQuestions[2]),
                        AudioQuestion(focus: Presets.audioSources[5].id,
                                      chosenQuestion: Presets.possibleQuestions[3]),
                    ],
                    backgroundResourceLink: "Train"),
        HearingTest(name: "Café",
                    audioSources: [
                        Presets.audioSources[6],
                        Presets.audioSources[7],
                        Presets.audioSources[8],
                        Presets.audioSources[9],
                    ],
                    questions: [
                        AudioQuestion(focus: Presets.audioSources[6].id,
                                      chosenQuestion: Presets.possibleQuestions[8]),
                        AudioQuestion(focus: Presets.audioSources[7].id,
                                      chosenQuestion: Presets.possibleQuestions[9]),
                    ],
                    backgroundResourceLink: "Cafe")
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
                         correctAnswer: 2,
                         duration: .seconds(10)),
        PossibleQuestion(audioResourceLink: "Police.mp3",
                         question: "Test Question 2?",
                         answers: [
                            "Correct 1",
                            "Incorrect 2",
                            "Incorrect 3",
                            "Incorrect 4"
                         ],
                         correctAnswer: 0,
                         duration: .seconds(10)),
        /// Created by Yu-Han Chang on 22 March.
        PossibleQuestion(audioResourceLink: "Train_Announcement.mp3",
                         question: "Which platform will the next train arrive on?",
                         answers: [
                            "Platform 21",
                            "Platform 33",
                            "Platform 23",
                            "Platform 22"
                         ],
                         correctAnswer: 2,
                         duration: .seconds(11)),
        PossibleQuestion(audioResourceLink: "Train_Announcement.mp3",
                         question: "Which is the first stop of this train going to Macarthur?",
                         answers: [
                            "Mascot",
                            "Green Square",
                            "Domestic Airport",
                            "International Airport"
                         ],
                         correctAnswer: 1,
                         duration: .seconds(19)),
        PossibleQuestion(audioResourceLink: "Train_Announcement.mp3",
                         question: "Which Airport stop will come first for this train going to Macarthur?",
                         answers: [
                            "Domestic Airport",
                            "International Airport",
                            "Sydney Airport",
                            "None of them"
                         ],
                         correctAnswer: 0,
                         duration: .seconds(31)),
        PossibleQuestion(audioResourceLink: "Home_WeatherForecast.mp3",
                         question: "What weather is expected in Sydney tomorrow?",
                         answers: ["Mostly cloudy", "Stormy", "Mostly raining", "Mostly sunny"],
                         correctAnswer: 3,
                         duration: .seconds(23)),
        PossibleQuestion(audioResourceLink: "Home_WeatherForecast.mp3",
                         question: "What is the highest temperature expected in Canberra tomorrow?",
                         answers: ["25", "30", "35", "40"],
                         correctAnswer: 2,
                         duration: .seconds(27)),
        PossibleQuestion(audioResourceLink: "Home_WeatherForecast.mp3",
                         question: "How were western areas expected to be?",
                         answers: ["Hot to very hot", "Cold to very cold", "Rainy", "Sunny"],
                         correctAnswer: 0,
                         duration: .seconds(15)),
        // Additional questions temporarily input by Tian Lang Hin on 5 April.
        PossibleQuestion(audioResourceLink: "Cafe_Worker.mp3",
                         question: "What sides does the sandwiches come with?",
                         answers: ["Salad and drinks", "Chips", "A drink", "Chips or salad"],
                         correctAnswer: 3,
                         duration: .seconds(16)),
        PossibleQuestion(audioResourceLink: "Cafe_Worker.mp3",
                         question: "How much does the extra poached egg cost?",
                         answers: ["One dollar", "Two dollars", "Three dollars", "Four dollars"],
                         correctAnswer: 1,
                         duration: .seconds(21)),
        PossibleQuestion(audioResourceLink: "Cafe_Worker.mp3",
                         question: "What is their new drink currently under promotion?",
                         answers: ["Iced caramel latte", "Iced vanilla latte", "Chai latte", "Iced matcha"],
                         correctAnswer: 0,
                         duration: .seconds(30)),
    ]

    static var conversationAudioClips: [String] = [
        "Police.mp3",
        "AudioSample1.mp3",
        "AudioSample2.mp3",
        "Train_Announcement.mp3",
        "Home_WeatherForecast.mp3",
    ]

    static var ambientAudioClips: [String] = [
        "FunkySynth.mp3",
        "Cafe_Ambience.mp3",
        "Cafe_Music.mp3",
        "Train_Birds.mp3",
        "Train_Departing.mp3",
        "Train_PeopleTalking.mp3",
    ]
}
