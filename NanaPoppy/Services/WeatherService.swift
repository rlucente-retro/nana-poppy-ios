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

class WeatherService {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func getCurrentWeather(query: String) async throws -> WeatherResponse {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        var geocodeComponents = URLComponents(string: "https://geocoding-api.open-meteo.com/v1/search")!
        geocodeComponents.queryItems = [
            URLQueryItem(name: "name", value: trimmedQuery),
            URLQueryItem(name: "count", value: "1")
        ]
        
        guard let geocodeUrl = geocodeComponents.url else {
            throw URLError(.badURL)
        }
        
        var geocodeRequest = URLRequest(url: geocodeUrl)
        geocodeRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        let (geocodeData, geocodeResponse) = try await session.data(for: geocodeRequest)
        
        guard let httpGeocodeResponse = geocodeResponse as? HTTPURLResponse, httpGeocodeResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let geocodeResult = try JSONDecoder().decode(OpenMeteoGeocodingResponse.self, from: geocodeData)
        guard let location = geocodeResult.results?.first else {
            throw NSError(domain: "WeatherService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Location not found for query: \(trimmedQuery)"])
        }
        
        var weatherComponents = URLComponents(string: "https://api.open-meteo.com/v1/forecast")!
        weatherComponents.queryItems = [
            URLQueryItem(name: "latitude", value: String(location.latitude)),
            URLQueryItem(name: "longitude", value: String(location.longitude)),
            URLQueryItem(name: "current", value: "temperature_2m"),
            URLQueryItem(name: "temperature_unit", value: "fahrenheit")
        ]
        
        guard let weatherUrl = weatherComponents.url else {
            throw URLError(.badURL)
        }
        
        var weatherRequest = URLRequest(url: weatherUrl)
        weatherRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        let (weatherData, weatherResponse) = try await session.data(for: weatherRequest)
        
        guard let httpWeatherResponse = weatherResponse as? HTTPURLResponse, httpWeatherResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let openMeteoWeather = try JSONDecoder().decode(OpenMeteoWeatherResponse.self, from: weatherData)
        
        return WeatherResponse(
            main: MainData(temp: openMeteoWeather.current.temperature_2m),
            name: location.name
        )
    }
}

private struct OpenMeteoGeocodingResponse: Codable {
    let results: [GeocodingResult]?
}

private struct GeocodingResult: Codable {
    let latitude: Double
    let longitude: Double
    let name: String
}

private struct OpenMeteoWeatherResponse: Codable {
    struct CurrentWeather: Codable {
        let temperature_2m: Float
    }
    let current: CurrentWeather
}
