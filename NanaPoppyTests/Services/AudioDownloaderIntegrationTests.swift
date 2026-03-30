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
import ZIPFoundation

final class AudioDownloaderIntegrationTests: XCTestCase {
    private var downloader: AudioDownloader!
    private var fileManager: FileManager!
    private var audioDir: URL!

    override func setUp() {
        super.setUp()
        downloader = AudioDownloader()
        fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        audioDir = documentsURL.appendingPathComponent("audio")
        
        // Clean up before each test
        if fileManager.fileExists(atPath: audioDir.path) {
            try? fileManager.removeItem(at: audioDir)
        }
        
        URLProtocol.registerClass(MockURLProtocol.self)
    }

    override func tearDown() {
        if fileManager.fileExists(atPath: audioDir.path) {
            try? fileManager.removeItem(at: audioDir)
        }
        URLProtocol.unregisterClass(MockURLProtocol.self)
        super.tearDown()
    }

    func testSyncWithGoogleDriveVirusWarningFlow() async throws {
        let fileId = "test_file_id"
        let initialUrl = "https://drive.google.com/file/d/\(fileId)/view"
        let confirmToken = "tOkEn_123"
        
        // 1. Mock the first response (the virus scan warning page)
        let warningHtml = """
        <html>
            <body>
                <a href="/uc?export=download&id=\(fileId)&confirm=\(confirmToken)">Download anyway</a>
            </body>
        </html>
        """
        
        // 2. Create a dummy zip file for the second response
        let tempZip = fileManager.temporaryDirectory.appendingPathComponent("integration_test.zip")
        if fileManager.fileExists(atPath: tempZip.path) {
            try fileManager.removeItem(at: tempZip)
        }
        let archive = try Archive(url: tempZip, accessMode: .create)
        try archive.addEntry(with: "wrapper/child1/greeting.mp3", type: .file, uncompressedSize: Int64(4), provider: { (_, _) in
            return "data".data(using: .utf8)!
        })
        try archive.addEntry(with: "wrapper/child2/greeting.mp3", type: .file, uncompressedSize: Int64(4), provider: { (_, _) in
            return "data".data(using: .utf8)!
        })
        let zipData = try Data(contentsOf: tempZip)
        
        // 3. Setup MockURLProtocol to handle the flow
        var callCount = 0
        MockURLProtocol.requestHandler = { request in
            callCount += 1
            if request.url?.absoluteString.contains("confirm=") == true {
                // Second call: the actual file download
                let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: ["Content-Type": "application/zip"])!
                return (response, zipData)
            } else {
                // First call: the warning page
                let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: ["Content-Type": "text/html; charset=UTF-8"])!
                return (response, warningHtml.data(using: .utf8)!)
            }
        }
        
        // 4. Run the sync
        let success = try await downloader.downloadAndUnzip(url: initialUrl)
        
        // 5. Assertions
        XCTAssertTrue(success)
        XCTAssertEqual(callCount, 2)
        XCTAssertTrue(fileManager.fileExists(atPath: audioDir.appendingPathComponent("child1/greeting.mp3").path))
        XCTAssertTrue(fileManager.fileExists(atPath: audioDir.appendingPathComponent("child2/greeting.mp3").path))
        
        // 6. Verify validation logic works too
        let validation = downloader.validate()
        XCTAssertEqual(validation.children.count, 2)
        if let firstChild = validation.children.first(where: { $0.name == "child1" }) {
            XCTAssertEqual(firstChild.name, "child1")
        } else {
            XCTFail("child1 not found in validation results")
        }
    }
}

