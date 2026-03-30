/*
 * Copyright 2026 Richard Lucente
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation

enum NumberToWords {
    private static let lowNames = [
        "zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten",
        "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen"
    ]

    private static let tensNames = [
        "twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety"
    ]

    private static let ordinalNames = [
        "one": "first", "two": "second", "three": "third", "four": "fourth", "five": "fifth",
        "six": "sixth", "seven": "seventh", "eight": "eighth", "nine": "ninth", "ten": "tenth",
        "eleven": "eleventh", "twelve": "twelfth", "thirteen": "thirteenth", "fourteen": "fourteenth",
        "fifteen": "fifteenth", "sixteen": "sixteenth", "seventeen": "seventeenth", "eighteen": "eighteenth",
        "nineteen": "nineteenth", "twenty": "twentieth", "thirty": "thirtieth", "forty": "fortieth",
        "fifty": "fiftieth", "sixty": "sixtieth", "seventy": "seventieth", "eighty": "eightieth",
        "ninety": "ninetieth"
    ]

    static func convert(_ number: Int) -> [String] {
        if number < 20 { return [lowNames[number]] }
        if number < 100 {
            let tens = tensNames[number / 10 - 2]
            let ones = number % 10
            return ones == 0 ? [tens] : [tens, lowNames[ones]]
        }
        return [String(number)] // Fallback for simplicity
    }

    static func convertOrdinal(_ number: Int) -> [String] {
        let words = convert(number)
        guard let lastWord = words.last else { return [] }
        let ordinal = ordinalNames[lastWord] ?? (lastWord + "th")
        return words.dropLast() + [ordinal]
    }
}
