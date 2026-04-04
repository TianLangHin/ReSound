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
struct CustomTest {
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

    func generateTest() -> HearingTest {
        return .init(name: "", audioSources: [], questions: [], backgroundResourceLink: "")
    }
    
    enum Theme {
        case home
        case cafe
        case train

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

    enum Positioning {
        case easy
        case medium
        case hard
    }
}
