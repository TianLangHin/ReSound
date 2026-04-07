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
struct HearingTest: Hashable, Codable {
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
struct AudioSource: Equatable, Hashable, Codable {
    // This `id` attribute allows other structures to easily reference a particular audio source.
    // Have to make this mutable for Codable (idk if there is another way)
    var id = UUID()
    // This will allow customisation by the clinician to adjust the difficulty of the hearing tests.
    // It affects which list of audio files it will take from.
    var type: AudioSourceType
    // Location relative to the user.
    var location: SIMD3<Float>
    // Ideally, this will be an enum of choices between various preset assets.
    var visualResourceLink: VisualResourceType

    enum VisualResourceType: Equatable, Hashable, Codable {
        case presetBox
        case asset(String)
    }

    enum AudioSourceType: Equatable, Hashable, Codable {
        case conversation(String?)
        case ambient(String?)
        case silent
    }
}

/// This represents a particular instance of a `PossibleQuestion` being applied to a `HearingTest`.
/// This carries the specific information about a question directly applicable to a specific hearing test,
/// with the "template" information being available via `chosenQuestion` instead.
struct AudioQuestion: Equatable, Hashable, Codable {
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
struct PossibleQuestion: Equatable, Hashable, Codable {
    let audioResourceLink: String
    let question: String
    let answers: [String]
    let correctAnswer: Int
    let duration: Duration
    
    
    // Have to convert duration from Duration datatype to Double here for JSON encode
    enum QuestionCodingKeys: String, CodingKey {
        case audioResourceLink, question, answers, correctAnswer, durationInDouble
    }
 
    // Normal initialiser to conform with Codable
    init(audioResourceLink: String, question: String, answers: [String],
         correctAnswer: Int, duration: Duration) {
        self.audioResourceLink = audioResourceLink
        self.question = question
        self.answers = answers
        self.correctAnswer = correctAnswer
        self.duration = duration
    }
    
    
    // Initialiser to store the information for possible questions after decoding from JSON format
    init(from decoder: Decoder) throws {
        let questionContainer = try decoder.container(keyedBy: QuestionCodingKeys.self)
        audioResourceLink = try questionContainer.decode(String.self, forKey: .audioResourceLink)
        question = try questionContainer.decode(String.self, forKey: .question)
        answers = try questionContainer.decode([String].self, forKey: .answers)
        correctAnswer = try questionContainer.decode(Int.self, forKey: .correctAnswer)
        let seconds = try questionContainer.decode(Double.self, forKey: .durationInDouble)
        duration = .seconds(seconds)
    }
    
    // Encoding possible questions
    func encode(to encoder: Encoder) throws {
        var questionContainer = encoder.container(keyedBy: QuestionCodingKeys.self)
        try questionContainer.encode(audioResourceLink, forKey: .audioResourceLink)
        try questionContainer.encode(question, forKey: .question)
        try questionContainer.encode(answers, forKey: .answers)
        try questionContainer.encode(correctAnswer, forKey: .correctAnswer)
        
        // Duration have to be converted to Double for storage from "https://forums.swift.org/t/converting-a-duration-to-a-double-of-seconds/63080/4"
        let seconds = Double(duration.components.seconds) + Double(duration.components.attoseconds) * 1e-18
        try questionContainer.encode(seconds, forKey: .durationInDouble)
    }
}



// Overwrite Swift's SIMD3 - reference from: "https://stackoverflow.com/questions/63661474/how-can-i-encode-an-array-of-simd-float4x4-elements-in-swift-convert-simd-float"
// Ignore the warning here
extension SIMD3: Codable where Scalar == Float {
    enum CodingKeys: String, CodingKey { case x, y, z }

    public init(from decoder: Decoder) throws {
        let locationContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.init(try locationContainer.decode(Float.self, forKey: .x),
                  try locationContainer.decode(Float.self, forKey: .y),
                  try locationContainer.decode(Float.self, forKey: .z))
    }

    // Encode location
    public func encode(to encoder: Encoder) throws {
        var locationContainer = encoder.container(keyedBy: CodingKeys.self)
        try locationContainer.encode(x, forKey: .x)
        try locationContainer.encode(y, forKey: .y)
        try locationContainer.encode(z, forKey: .z)
    }
}

