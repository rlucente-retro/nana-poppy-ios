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

final class MainViewModelTests: XCTestCase {
    private var viewModel: MainViewModel!
    private var mockWeatherService: MockWeatherService!
    private var mockSettings: MockSettingsRepository!
    private var mockPlayer: MockAudioPlayer!

    override func setUp() {
        super.setUp()
        mockWeatherService = MockWeatherService()
        mockSettings = MockSettingsRepository()
        mockPlayer = MockAudioPlayer()
        
        // Mock audio directory
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioDir = documentsURL.appendingPathComponent("audio")
        
        // Clean up previous test state
        try? fileManager.removeItem(at: audioDir)
        
        let child1Dir = audioDir.appendingPathComponent("child1")
        try? fileManager.createDirectory(at: child1Dir, withIntermediateDirectories: true)
        
        // Create mock locations.json
        let locations = LocationData(location1: "Waynesboro,PA,US", location2: "Ocean City,MD,US")
        if let data = try? JSONEncoder().encode(locations) {
            try? data.write(to: audioDir.appendingPathComponent("locations.json"))
        }
        
        viewModel = MainViewModel(weatherService: mockWeatherService, settings: mockSettings, player: mockPlayer)
    }

    func testPlaySuccess() async {
        mockSettings.configured = true
        mockSettings.apiKey = "fake_key"
        
        let startExpectation = XCTestExpectation(description: "Playback started")
        mockPlayer.onPlayPlaylist = {
            startExpectation.fulfill()
        }
        
        let finishExpectation = XCTestExpectation(description: "Playback finished")
        mockPlayer.onCompleteCalled = {
            finishExpectation.fulfill()
        }

        await MainActor.run {
            viewModel.play()
        }
        
        await fulfillment(of: [startExpectation], timeout: 5.0)
        
        await MainActor.run {
            XCTAssertNotNil(viewModel.currentChildId)
            XCTAssertEqual(viewModel.currentChildId, "child1")
        }
        
        await fulfillment(of: [finishExpectation], timeout: 5.0)
        
        XCTAssertTrue(mockWeatherService.getCurrentWeatherCalled)
        XCTAssertTrue(mockPlayer.playPlaylistCalled)
        XCTAssertNil(viewModel.currentChildId)
    }
}

class MockWeatherService: WeatherService {
    var getCurrentWeatherCalled = false
    override func getCurrentWeather(query: String, apiKey: String) async throws -> WeatherResponse {
        getCurrentWeatherCalled = true
        return WeatherResponse(main: MainData(temp: 72.5), name: query)
    }
}

class MockSettingsRepository: SettingsRepository {
    var configured = false
    var apiKey: String?
    
    override func isConfigured() -> Bool {
        return configured
    }
    
    override var owmApiKey: String? {
        get { apiKey }
        set { apiKey = newValue }
    }
}

class MockAudioPlayer: AudioPlayer {
    var playPlaylistCalled = false
    var onPlayPlaylist: (() -> Void)?
    var onCompleteCalled: (() -> Void)?
    
    override func playPlaylist(segments: [(childId: String, words: [String])], 
                               onSegmentChange: @escaping (String) -> Void,
                               onComplete: @escaping () -> Void) {
        playPlaylistCalled = true
        onSegmentChange(segments.first?.childId ?? "unknown")
        onPlayPlaylist?()
        
        // Delay completion to simulate asynchronous playback
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            onComplete()
            self.onCompleteCalled?()
        }
    }
}
