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

import XCTest
@testable import NanaPoppy

final class NumberToWordsTests: XCTestCase {

    func testConvertLowNumbers() {
        XCTAssertEqual(NumberToWords.convert(0), ["zero"])
        XCTAssertEqual(NumberToWords.convert(5), ["five"])
        XCTAssertEqual(NumberToWords.convert(10), ["ten"])
        XCTAssertEqual(NumberToWords.convert(19), ["nineteen"])
    }

    func testConvertTens() {
        XCTAssertEqual(NumberToWords.convert(20), ["twenty"])
        XCTAssertEqual(NumberToWords.convert(30), ["thirty"])
        XCTAssertEqual(NumberToWords.convert(90), ["ninety"])
    }

    func testConvertCompoundNumbers() {
        XCTAssertEqual(NumberToWords.convert(21), ["twenty", "one"])
        XCTAssertEqual(NumberToWords.convert(55), ["fifty", "five"])
        XCTAssertEqual(NumberToWords.convert(99), ["ninety", "nine"])
    }

    func testConvertOrdinal() {
        XCTAssertEqual(NumberToWords.convertOrdinal(1), ["first"])
        XCTAssertEqual(NumberToWords.convertOrdinal(2), ["second"])
        XCTAssertEqual(NumberToWords.convertOrdinal(3), ["third"])
        XCTAssertEqual(NumberToWords.convertOrdinal(4), ["fourth"])
        XCTAssertEqual(NumberToWords.convertOrdinal(21), ["twenty", "first"])
        XCTAssertEqual(NumberToWords.convertOrdinal(30), ["thirtieth"])
        XCTAssertEqual(NumberToWords.convertOrdinal(31), ["thirty", "first"])
    }
}
