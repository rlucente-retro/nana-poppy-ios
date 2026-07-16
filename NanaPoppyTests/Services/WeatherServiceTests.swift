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

final class WeatherServiceTests: XCTestCase {
    private var service: WeatherService!
    private var session: URLSession!

    override func setUp() {
        super.setUp()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: configuration)
        service = WeatherService(session: session)
    }

    func testGetCurrentWeatherSuccess() async throws {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            if request.url?.host == "geocoding-api.open-meteo.com" {
                let json = """
                {
                    "results": [
                        {
                            "latitude": 39.7562,
                            "longitude": -77.5811,
                            "name": "Test City"
                        }
                    ]
                }
                """.data(using: .utf8)!
                return (response, json)
            } else {
                let json = """
                {
                    "current": {
                        "temperature_2m": 72.5
                    }
                }
                """.data(using: .utf8)!
                return (response, json)
            }
        }

        let response = try await service.getCurrentWeather(query: "Test City")

        XCTAssertEqual(response.main.temp, 72.5)
        XCTAssertEqual(response.name, "Test City")
    }

    func testGetCurrentWeatherFailure() async {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let json = """
            {
                "results": []
            }
            """.data(using: .utf8)!
            return (response, json)
        }

        do {
            _ = try await service.getCurrentWeather(query: "Test City")
            XCTFail("Expected error to be thrown")
        } catch {
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, "WeatherService")
            XCTAssertEqual(nsError.code, 404)
        }
    }
}

class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            XCTFail("Handler is nil")
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
