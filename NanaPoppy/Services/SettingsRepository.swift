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

class SettingsRepository {
    private let defaults = UserDefaults.standard

    var owmApiKey: String? {
        get { KeychainHelper.load(key: "owm_api_key") }
        set {
            if let value = newValue, !value.isEmpty {
                KeychainHelper.save(key: "owm_api_key", data: value)
            } else {
                KeychainHelper.delete(key: "owm_api_key")
            }
        }
    }

    var zipUrl: String? {
        get { defaults.string(forKey: "zip_url") }
        set { defaults.set(newValue, forKey: "zip_url") }
    }

    func isConfigured() -> Bool {
        return owmApiKey != nil && !owmApiKey!.trimmingCharacters(in: .whitespaces).isEmpty &&
               zipUrl != nil && !zipUrl!.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
