//
//  Storage.swift
//  ReSound
//
//  Created by Dương Anh Trần on 4/4/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

import Foundation

@Observable
class PersistStorage {
    static let testStorage = PersistStorage()
    private let key = "resound.hearingTests"
    private let scoreKey = "resound.scores"

    // Have to save custom test for extra variable too (I dont want to add more stuffs in HearingTest.Swift)
    func saveCustom(_ customs: [CustomTest]) {
        if let data = try? JSONEncoder().encode(customs) {
            UserDefaults.standard.set(data, forKey: "resound.customTests")
        }
    }

    func loadCustom() -> [CustomTest] {
        guard let data = UserDefaults.standard.data(forKey: "resound.customTests"),
              let customs = try? JSONDecoder().decode([CustomTest].self, from: data)
        else { return [] }
        return customs
    }
    
    func saveScore(_ tests: [ScoreBreakdown]) {
        if let data = try? JSONEncoder().encode(tests) {
            UserDefaults.standard.set(data, forKey: scoreKey)
        }
    }
    
    
    func loadScore() -> [ScoreBreakdown] {
        guard let data = UserDefaults.standard.data(forKey: "resound.scores"),
              let scores = try? JSONDecoder().decode([ScoreBreakdown].self, from: data)
        else { return [] }
        return scores.sorted { $0.timeAttempted > $1.timeAttempted }
    }
}
