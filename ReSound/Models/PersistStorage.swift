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
    
    func saveTest(_ tests: [HearingTest]) {
        if let data = try? JSONEncoder().encode(tests) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    func loadTest() -> [HearingTest] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let tests = try? JSONDecoder().decode([HearingTest].self, from: data)
        else { return [] }
        return tests
    }
    
    
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
}
