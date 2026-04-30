//
//  CustomTest.swift
//  ReSound
//
//  Created by Tian Lang Hin on 4/4/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

/// This struct represents a customisable hearing test,
/// and can be used to generate a `HearingTest` instance when required.
/// This makes it easier to manipulate particular settings that the clinician
/// will care about, while abstracting away the ways in which that affects
/// the actual attributes of the equivalent `HearingTest` instance.
/// This also includes random question generation depending on the theme.
///
import Foundation
import RealityKit

struct CustomTest: Codable {
    var id: UUID = UUID()
    var name: String
    var background: Theme
    var positioning: Positioning
    var targetVolume: Double
    var numberOfQuestions: Int

    init() {
        self.name = "Custom Test"
        self.background = .home
        self.positioning = .easy
        self.targetVolume = 0.0
        self.numberOfQuestions = 1
    }

    enum Theme: Codable {
        case home
        case cafe
        case train

        func resourceLink() -> String {
            switch self {
            case .home:
                return "Home"
            case .cafe:
                return "Cafe"
            case .train:
                return "Train"
            }
        }

        func prefix() -> String {
            switch self {
            case .home:
                return "Home_"
            case .cafe:
                return "Cafe_"
            case .train:
                return "Train_"
            }
        }
    }

    enum Positioning: Codable {
        case easy
        case medium
        case hard
    }

    func generateTest() -> HearingTest {
        let targetAudioSources = self.generateTargetAudio(self.background)
        let (leftDistractor, rightDistractor) = self.generateDistractorSources(self.positioning, self.background)
        let ambientSources = self.generateAmbientSources(self.background)
        let possibleQuestions = Presets.possibleQuestions.filter({
            $0.audioResourceLink.starts(with: self.background.prefix())
        })
        var allQuestions: [(AudioSource, PossibleQuestion)] = []
        for audioSource in targetAudioSources {
            for possibleQuestion in possibleQuestions {
                allQuestions.append((audioSource, possibleQuestion))
            }
        }
        let chosenQuestions = allQuestions.shuffled().prefix(self.numberOfQuestions).map { (audio, question) in
            AudioQuestion(
                focus: audio.id,
                chosenQuestion: question,
                volumeLevel: self.targetVolume)
        }
        return .init(
            name: self.name,
            audioSources: targetAudioSources + [leftDistractor, rightDistractor] + ambientSources,
            questions: chosenQuestions,
            backgroundResourceLink: self.background.resourceLink())
    }

    func generateTargetAudio(_ theme: Theme) -> [AudioSource] {
        switch self.background {
        case .home:
            let tv = AudioSource(
                type: .silent,
                location: .init(x: 0.0, y: 0.0, z: -1.0),
                visualResourceLink: .asset("Home_TV.usdz"))
            return [tv]
        case .cafe:
            let serverLeft = AudioSource(
                type: .silent,
                location: .init(x: -0.5, y: 0.1, z: -2.8),
                visualResourceLink: .animated("ANIM_StandingWoman4.usdz"))
            let serverRight = AudioSource(
                type: .silent,
                location: .init(x: 0.5, y: 0.25, z: -2.8),
                visualResourceLink: .animated("ANIM_StandingWoman2.usdz"))
            return [serverLeft, serverRight]
        case .train:
            let speakerLeft = AudioSource(
                type: .silent,
                location: .init(x: 0.8, y: 0.6, z: -2.5),
                visualResourceLink: .asset("Train_Loudspeaker.usdz"),
                orientation: simd_quatf(angle: -.pi / 2, axis: [0, 1, 0]))
            let speakerRight = AudioSource(
                type: .silent,
                location: .init(x: 0.8, y: 0.6, z: 1.5),
                visualResourceLink: .asset("Train_Loudspeaker.usdz"),
                orientation: simd_quatf(angle: -.pi / 2, axis: [0, 1, 0]))
            return [speakerLeft, speakerRight]
        }
    }

    func generateDistractorLocations(_ positioning: Positioning, _ theme: Theme) -> (SIMD3<Float>, SIMD3<Float>) {
        switch theme {
        case .cafe:
            switch positioning {
            case .easy:
                return (.init(x: 1.0, y: 0.45, z: 2.5), .init(x: 4.5, y: 0.6, z: 2.5))
            case .medium:
                return (.init(x: -0.3, y: 0.45, z: 1.0), .init(x: 3.5, y: 0.6, z: -1.7))
            case .hard:
                return (.init(x: 0, y: 0.45, z: 0.7), .init(x: 2.0, y: 0.6, z: -0.5))
            }
        default:
            switch positioning {
            case .easy:
                return (.init(x: -2.0, y: 0.0, z: -0.5), .init(x: 2.0, y: 0.0, z: -0.5))
            case .medium:
                return (.init(x: -1.5, y: 0.0, z: -1.0), .init(x: 1.5, y: 0.0, z: -1.0))
            case .hard:
                return (.init(x: -1.0, y: 0.0, z: -1.5), .init(x: 1.0, y: 0.0, z: -1.5))
            }
        }
    }

    func generateDistractorSources(_ positioning: Positioning, _ theme: Theme) -> (AudioSource, AudioSource) {
        let (leftLocation, rightLocation) = generateDistractorLocations(positioning, theme)

        var leftDistractor: AudioSource, rightDistractor: AudioSource

        switch theme {
        case .home:
            leftDistractor = AudioSource(
                type: .ambient("Home_CatSound.mp3"),
                location: leftLocation,
                visualResourceLink: .asset("Home_Cat.usdz"))
            rightDistractor = AudioSource(
                type: .conversation("AudioSample1.mp3"),
                location: rightLocation,
                visualResourceLink: .asset("Man1.usdz"))
        case .cafe:
            leftDistractor = AudioSource(
                type: .conversation("AudioSample1.mp3"),
                location: leftLocation,
                visualResourceLink: .animated("ANIM_StandingMan1.usdz"))
            rightDistractor = AudioSource(
                type: .conversation("WaitressServingTable.mp3"),
                location: rightLocation,
                visualResourceLink: .asset("Woman3.usdz"))
            switch positioning {
            case .easy:
                leftDistractor.orientation = simd_quatf(angle: .pi, axis: [0, 1, 0])
                rightDistractor.orientation = simd_quatf(angle: -.pi / 2, axis: [0, 1, 0])
            case .medium:
                leftDistractor.orientation = simd_quatf(angle: .pi, axis: [0, 1, 0])
            case .hard:
                leftDistractor.orientation = simd_quatf(angle: .pi / 2, axis: [0, 1, 0])
                rightDistractor.orientation = simd_quatf(angle: .pi / 2, axis: [0, 1, 0])
            }
        case .train:
            leftDistractor = AudioSource(
                type: .ambient("Train_Birds.mp3"),
                location: leftLocation,
                visualResourceLink: .asset("Train_Pigeon.usdz"))
            rightDistractor = AudioSource(
                type: .ambient("Train_PeopleTalking.mp3"),
                location: rightLocation,
                visualResourceLink: .asset("Man2.usdz"))
        }
        return (leftDistractor, rightDistractor)
    }

    func generateAmbientSources(_ background: Theme) -> [AudioSource] {
        switch background {
        case .home:
            return [
                // The ambient noise for the home environment has distant people talking and a car passing by outside.
                AudioSource(type: .ambient("Home_People Talking.mp3"),
                            location: .init(x: -5.0, y: 0.0, z: -1.0),
                            visualResourceLink: .asset("")),
                AudioSource(type: .ambient("Home_CarPassing.mp3"),
                            location: .init(x: 4.0, y: 0.0, z: 1.0),
                            visualResourceLink: .asset("")),
            ]
        case .cafe:
            return [
                AudioSource(type: .ambient("Cafe_Music.mp3"),
                            location: .init(x: 0.0, y: 5.0, z: 0.0),
                            visualResourceLink: .asset("")),
                AudioSource(type: .silent,
                            location: .init(x: 1.0, y: 0.85, z: 0.7),
                            visualResourceLink: .animated("ANIM_StandingOldMan.usdz"),
                            orientation: simd_quatf(angle: -.pi / 2, axis: [0, 1, 0])),
                AudioSource(type: .ambient("Cafe_Ambience.mp3"),
                            location: .init(x: 3.0, y: 0.0, z: 3.0),
                            visualResourceLink: .asset(""))
            ]
        case .train:
            return [
                // Train departing on the left, with a crowd of people on the right in conversation.
                AudioSource(type: .ambient("Train_Departing.mp3"),
                            location: .init(x: 0.0, y: 0.2, z: 0.0),
                            visualResourceLink: .animated("TrainCarriage_Resized.usdz")),
                AudioSource(type: .ambient("Train_Departing.mp3"),
                            location: .init(x: 0.0, y: 0.25, z: 13.0),
                            visualResourceLink: .animated("TrainCarriage_Resized.usdz")),
                AudioSource(type: .ambient("Train_Departing.mp3"),
                            location: .init(x: 0.0, y: 0.25, z: -13.0),
                            visualResourceLink: .animated("TrainCarriage_Resized.usdz")),
                AudioSource(type: .conversation("Train_PeopleTalking.mp3"),
                            location: .init(x: 1.5, y: 0.0, z: -0.5),
                            visualResourceLink: .asset("Woman1.usdz")),
                AudioSource(type: .silent,
                            location: .init(x: 1.3, y: 0.0, z: -0.7),
                            visualResourceLink: .asset("Woman2.usdz")),
                AudioSource(type: .silent,
                            location: .init(x: 1.7, y: 0.0, z: -0.9),
                            visualResourceLink: .asset("OldMan.usdz")),
            ]
        }
    }
}
