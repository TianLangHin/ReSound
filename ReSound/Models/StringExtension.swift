//
//  StringExtension.swift
//  ReSound
//
//  Created by Dương Anh Trần on 21/4/2026.
//  Copyright © 2026 Apple. All rights reserved.
//
import Foundation

public extension String {
    // To acount for different types of numbers
    func wordToInteger() -> Int? {
        let small: [String: Int] = [
            "zero": 0, "one": 1, "two": 2, "three": 3, "four": 4,
            "five": 5, "six": 6, "seven": 7, "eight": 8, "nine": 9,
            "ten": 10, "eleven": 11, "twelve": 12, "thirteen": 13,
            "fourteen": 14, "fifteen": 15, "sixteen": 16,
            "seventeen": 17, "eighteen": 18, "nineteen": 19
        ]

        let tens: [String: Int] = [
            "twenty": 20, "thirty": 30, "forty": 40,
            "fifty": 50, "sixty": 60, "seventy": 70,
            "eighty": 80, "ninety": 90
        ]

        let scales: [String: Int] = [
            "hundred": 100,
            "thousand": 1000
        ]

        var total = 0
        var current = 0

        for word in self.lowercased().split(separator: " ") {
            let w = String(word)

            if let n = small[w] {
                current += n
            } else if let n = tens[w] {
                current += n
            } else if let scale = scales[w] {
                current *= scale
                if scale >= 1000 {
                    total += current
                    current = 0
                }
            } else {
                return nil
            }
        }

        return total + current
    }
}

public func parseSpokenNumber(_ words: [String]) -> Int? {
    let stopWords: Set<String> = [
        "back", "save", "home", "cafe", "train", "easy", "medium",
        "hard", "add", "question", "number", "practice"
    ]

    let numberWords = Array(words.prefix(while: { !stopWords.contains($0) }))
        .filter { $0 != "and" }

    if numberWords.isEmpty { return nil }

    let spaced = numberWords.joined(separator: " ")
    let hyphenated = numberWords.joined(separator: "-")

    if let digit = Int(spaced) { return digit }
    if let number = spaced.wordToInteger() { return number }
    if let number = hyphenated.wordToInteger() { return number }
    return nil
}

