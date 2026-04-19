//
//  ScoreBreakdown.swift
//  ReSound
//
//  Created by Tian Lang Hin on 19/4/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

import Foundation

struct ScoreBreakdown {
    var hearingTestName: String
    var timeAttempted: Date
    var answers: [Answer]

    static func empty() -> Self {
        return ScoreBreakdown(hearingTestName: "", timeAttempted: Date(), answers: [])
    }

    mutating func addAnswer(_ answer: Answer) {
        self.answers.append(answer)
    }

    func overallScore() -> (Int, Int) {
        let correctQuestions = self.answers.count(where: { $0.isCorrect })
        let totalQuestions = self.answers.count
        return (correctQuestions, totalQuestions)
    }

    struct Answer {
        var questionText: String
        var selectedAnswer: String
        var isCorrect: Bool
    }
}
