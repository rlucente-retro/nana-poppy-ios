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
import SwiftUI

class SettingsViewModel: ObservableObject {
    @Published var owmApiKey: String = ""
    @Published var zipUrl: String = ""
    @Published var isSyncing = false
    @Published var syncResult: ValidationResult?
    @Published var showError = false
    @Published var errorMessage = ""

    private let settings = SettingsRepository()
    private let downloader = AudioDownloader()

    init() {
        owmApiKey = settings.owmApiKey ?? ""
        zipUrl = settings.zipUrl ?? ""
    }

    func save() {
        settings.owmApiKey = owmApiKey
        settings.zipUrl = zipUrl
    }

    func sync() {
        guard !zipUrl.isEmpty else {
            errorMessage = "ZIP URL is required"
            showError = true
            return
        }
        
        guard zipUrl.lowercased().starts(with: "https://") else {
            errorMessage = "ZIP URL must use a secure https:// connection"
            showError = true
            return
        }

        isSyncing = true
        Task {
            do {
                let success = try await downloader.downloadAndUnzip(url: zipUrl)
                await MainActor.run {
                    isSyncing = false
                    if success {
                        syncResult = downloader.validate()
                    } else {
                        errorMessage = "Sync Failed"
                        showError = true
                    }
                }
            } catch {
                await MainActor.run {
                    isSyncing = false
                    errorMessage = "Sync Error: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
}
