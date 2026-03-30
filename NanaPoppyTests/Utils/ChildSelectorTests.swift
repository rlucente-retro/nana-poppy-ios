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

final class ChildSelectorTests: XCTestCase {

    func testSelectMoreThanAvailable() {
        let available = ["A", "B"]
        let selected = ChildSelector.select(available: available, count: 4)
        
        XCTAssertEqual(selected.count, 4)
        XCTAssertTrue(selected.contains("A"))
        XCTAssertTrue(selected.contains("B"))
    }

    func testSelectFewerThanAvailable() {
        let available = ["A", "B", "C", "D", "E"]
        let selected = ChildSelector.select(available: available, count: 4)
        
        XCTAssertEqual(selected.count, 4)
        XCTAssertEqual(Set(selected).count, 4)
    }

    func testSelectExactlyAvailable() {
        let available = ["A", "B", "C", "D"]
        let selected = ChildSelector.select(available: available, count: 4)
        
        XCTAssertEqual(selected.count, 4)
        XCTAssertEqual(Set(selected).count, 4)
        XCTAssertTrue(Set(available).isSubset(of: Set(selected)))
    }

    func testSelectOneAvailable() {
        let available = ["A"]
        let selected = ChildSelector.select(available: available, count: 4)
        
        XCTAssertEqual(selected.count, 4)
        XCTAssertTrue(selected.allSatisfy { $0 == "A" })
    }
}
