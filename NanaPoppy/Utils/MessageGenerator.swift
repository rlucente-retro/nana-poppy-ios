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

enum MessageGenerator {

    static func generateDateMsg(now: Date) -> [String] {
        var msg = ["good"]
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)

        switch hour {
        case 0..<12: msg.append("morning")
        case 12..<17: msg.append("afternoon")
        case 17..<20: msg.append("evening")
        default: msg.append("night")
        }

        msg.append(contentsOf: ["nana_and_poppy", "today", "is"])
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "MMMM"
        msg.append(dateFormatter.string(from: now).lowercased())

        let day = calendar.component(.day, from: now)
        msg.append(contentsOf: NumberToWords.convertOrdinal(day))
        
        return msg
    }

    static func generateTimeMsg(now: Date) -> [String] {
        var msg = ["the_time", "is"]
        let calendar = Calendar.current
        var hour = calendar.component(.hour, from: now)
        let ampm = hour > 11 ? "pm" : "am"

        hour %= 12
        if hour == 0 { hour = 12 }

        msg.append(contentsOf: NumberToWords.convert(hour))

        let minute = calendar.component(.minute, from: now)
        if (1...9).contains(minute) {
            msg.append("oh")
        }
        if minute > 0 {
            msg.append(contentsOf: NumberToWords.convert(minute))
        }

        msg.append(ampm)
        return msg
    }

    static func generateTempMsg(location: String, temp: Int?) -> [String] {
        let formattedLocation = location.lowercased().replacingOccurrences(of: " ", with: "_")
        var msg = ["the_current_temperature_for", formattedLocation, "is"]

        if let temp = temp {
            var t = temp
            if t < 0 {
                msg.append("minus")
                t = -t
            }
            msg.append(contentsOf: NumberToWords.convert(t))
        } else {
            msg.append(contentsOf: ["minus", "minus"])
        }

        msg.append("degrees")
        return msg
    }
}
