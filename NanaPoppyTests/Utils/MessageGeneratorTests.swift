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

final class MessageGeneratorTests: XCTestCase {

    func testGenerateDateMsg() {
        var components = DateComponents()
        components.year = 2026
        components.month = 3 // March
        components.day = 29
        components.hour = 10 // Morning
        let calendar = Calendar.current
        let date = calendar.date(from: components)!

        let msg = MessageGenerator.generateDateMsg(now: date)
        
        XCTAssertTrue(msg.contains("morning"))
        XCTAssertTrue(msg.contains("march"))
        XCTAssertTrue(msg.contains("twenty"))
        XCTAssertTrue(msg.contains("ninth"))
    }

    func testGenerateTimeMsg() {
        var components = DateComponents()
        components.hour = 14 // 2 PM
        components.minute = 5
        let calendar = Calendar.current
        let date = calendar.date(from: components)!

        let msg = MessageGenerator.generateTimeMsg(now: date)
        
        XCTAssertEqual(msg[0], "the_time")
        XCTAssertEqual(msg[1], "is")
        XCTAssertTrue(msg.contains("two"))
        XCTAssertTrue(msg.contains("oh"))
        XCTAssertTrue(msg.contains("five"))
        XCTAssertTrue(msg.contains("pm"))
    }

    func testGenerateTempMsg() {
        let msg = MessageGenerator.generateTempMsg(location: "Waynesboro", temp: 72)
        
        XCTAssertTrue(msg.contains("waynesboro"))
        XCTAssertTrue(msg.contains("seventy"))
        XCTAssertTrue(msg.contains("two"))
        XCTAssertTrue(msg.contains("degrees"))
    }
    
    func testGenerateTempMsgMinus() {
        let msg = MessageGenerator.generateTempMsg(location: "North Pole", temp: -10)
        
        XCTAssertTrue(msg.contains("north_pole"))
        XCTAssertTrue(msg.contains("minus"))
        XCTAssertTrue(msg.contains("ten"))
    }
}
