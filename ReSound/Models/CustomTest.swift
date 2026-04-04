//
//  CustomTest.swift
//  ReSound
//
//  Created by Tian Lang Hin on 3/4/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

/// This struct represents a customisable hearing test,
/// and can be used to generate a `HearingTest` instance when required.
/// This makes it easier to manipulate particular settings that the clinician
/// will care about, while abstracting away the ways in which that affects
/// the actual attributes of the equivalent `HearingTest` instance.
/// This also includes random question generation depending on the theme.
struct CustomTest {
    var name: String
    var background: Theme
    var positioning: Positioning
    var targetVolume: Double
    var numberOfQuestions: Int

    static func empty() -> Self {
        return .init(
            name: "Custom Test",
            background: .cafe,
            positioning: .hard,
            targetVolume: 0.0,
            numberOfQuestions: 1)
    }

    func generateTest() -> HearingTest {
        let testName = self.name
        let bgResourceLink = self.background.resourceLink()
        // This will likely be done eventually with a `switch (self.background, self.positioning)`.
        // The below is just a prototype/sketch.
        let audioSources: [AudioSource]
        var questions: [AudioQuestion] = []
        switch self.positioning {
        case .easy:
            let mainSource = AudioSource(
                type: .ambient(nil),
                location: .init(x: 0.0, y: 0.0, z: -1.0),
                visualResourceLink: .asset("BusinessMan.usdz"))
            // For easy, peripherals are placed clearly to the left and right.
            let leftPeripheral = AudioSource(
                type: .conversation("AudioSample1.mp3"),
                location: .init(x: -2.0, y: 0.0, z: -0.5),
                visualResourceLink: .asset("Man1.usdz"))
            let rightPeripheral = AudioSource(
                type: .conversation("AudioSample2.mp3"),
                location: .init(x: 2.0, y: 0.0, z: -0.5),
                visualResourceLink: .asset("BusinessMan.usdz"))
            audioSources = [mainSource, leftPeripheral, rightPeripheral]
            let ids = [mainSource.id, rightPeripheral.id]
            let possibleQs = [Presets.possibleQuestions[0], Presets.possibleQuestions[1]]
            for _ in 1...self.numberOfQuestions {
                questions.append(AudioQuestion(
                    focus: ids.randomElement()!,
                    chosenQuestion: possibleQs.randomElement()!,
                    duration: .seconds(10),
                    volumeLevel: targetVolume))
            }
        case .hard:
            let mainSource = AudioSource(
                type: .ambient(nil),
                location: .init(x: 0.0, y: 0.0, z: -1.5),
                visualResourceLink: .asset("BusinessMan.usdz"))
            // For hard, peripherals are placed closer to the source, but still behind it.
            let leftPeripheral = AudioSource(
                type: .conversation("AudioSample1.mp3"),
                location: .init(x: -0.5, y: 0.0, z: -2.0),
                visualResourceLink: .asset("Man1.usdz"))
            let rightPeripheral = AudioSource(
                type: .conversation("AudioSample2.mp3"),
                location: .init(x: 0.5, y: 0.0, z: -2.0),
                visualResourceLink: .asset("BusinessMan.usdz"))
            audioSources = [mainSource, leftPeripheral, rightPeripheral]
            let ids = [mainSource.id, rightPeripheral.id]
            let possibleQs = [Presets.possibleQuestions[0], Presets.possibleQuestions[1]]
            for _ in 1...self.numberOfQuestions {
                questions.append(AudioQuestion(
                    focus: ids.randomElement()!,
                    chosenQuestion: possibleQs.randomElement()!,
                    duration: .seconds(10),
                    volumeLevel: targetVolume))
            }
        }
        print("Test name: \(testName)")
        print("Number of questions: \(questions.count)")
        return HearingTest(
            name: testName,
            audioSources: audioSources,
            questions: questions,
            backgroundResourceLink: bgResourceLink)
    }

    enum Theme: Equatable {
        case home
        case cafe
        case train

        /// Returns the resource representing the background of the chosen theme.
        /// This is to be projected onto the inside of a sphere as a skybox.
        func resourceLink() -> String {
            switch self {
            case .home:
                return "small_empty_room_1_4k.hdr"
            case .cafe:
                return "bush_restaurant_4k.exr"
            case .train:
                return "dresden_station_night_4k.exr"
            }
        }
    }

    enum Positioning: Equatable {
        case easy
        case hard
    }
}
