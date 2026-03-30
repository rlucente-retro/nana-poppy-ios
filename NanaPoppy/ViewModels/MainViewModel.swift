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
import Combine

class MainViewModel: ObservableObject {
    @Published var isPlaying = false
    @Published var status: String?
    
    private let weatherService: WeatherService
    private let settings: SettingsRepository
    private let player: AudioPlayer
    
    init(weatherService: WeatherService = WeatherService(),
         settings: SettingsRepository = SettingsRepository(),
         player: AudioPlayer = AudioPlayer()) {
        self.weatherService = weatherService
        self.settings = settings
        self.player = player
    }
    
    func play() {
        guard settings.isConfigured() else {
            status = "Please configure settings first"
            return
        }
        
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioDir = documentsURL.appendingPathComponent("audio")
        
        var availableChildren: [String] = []
        if let contents = try? fileManager.contentsOfDirectory(at: audioDir, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) {
            availableChildren = contents.filter { $0.hasDirectoryPath }.map { $0.lastPathComponent }
        }
        
        guard !availableChildren.isEmpty else {
            status = "No audio files found. Please sync in settings."
            return
        }
        
        isPlaying = true
        status = nil
        
        Task {
            let now = Date()
            let temp1 = try? await fetchWeather(location: settings.location1Query)
            let temp2 = try? await fetchWeather(location: settings.location2Query)
            
            let selectedChildren = ChildSelector.select(available: availableChildren, count: 4)
            
            let messages: [(childId: String, words: [String])] = [
                (selectedChildren[0], MessageGenerator.generateDateMsg(now: now)),
                (selectedChildren[1], MessageGenerator.generateTimeMsg(now: now)),
                (selectedChildren[2], MessageGenerator.generateTempMsg(location: "location1", temp: temp1)),
                (selectedChildren[3], MessageGenerator.generateTempMsg(location: "location2", temp: temp2))
            ]
            
            await MainActor.run {
                player.playPlaylist(segments: messages) {
                    self.isPlaying = false
                }
            }
        }
    }
    
    private func fetchWeather(location: String) async throws -> Int? {
        do {
            let response = try await weatherService.getCurrentWeather(query: location, apiKey: settings.owmApiKey!)
            return Int(response.main.temp)
        } catch {
            await MainActor.run {
                status = "Weather Error (\(location)): \(error.localizedDescription)"
            }
            return nil
        }
    }
}
