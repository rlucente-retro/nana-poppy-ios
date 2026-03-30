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

enum ChildSelector {
    static func select(available: [String], count: Int) -> [String] {
        guard !available.isEmpty else { return [] }
        
        if available.count >= count {
            return Array(available.shuffled().prefix(count))
        } else {
            var list = available.shuffled()
            while list.count < count {
                if let random = available.randomElement() {
                    list.append(random)
                }
            }
            return list.shuffled()
        }
    }
}
