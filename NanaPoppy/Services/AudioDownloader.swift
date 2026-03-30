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
import ZIPFoundation

struct ChildStatus: Codable {
    let name: String
    let missingPhrases: [String]
}

struct ValidationResult: Codable {
    let children: [ChildStatus]
}

class AudioDownloader {
    private func convertGoogleDriveUrl(_ url: String) -> String {
        if !url.contains("drive.google.com") { return url }
        
        var fileId = ""
        if url.contains("/file/d/") {
            fileId = url.components(separatedBy: "/file/d/")[1].components(separatedBy: "/")[0]
        } else if url.contains("id=") {
            fileId = url.components(separatedBy: "id=")[1].components(separatedBy: "&")[0]
        } else {
            return url
        }
        
        return "https://drive.google.com/uc?export=download&id=\(fileId)"
    }

    func downloadAndUnzip(url: String) async throws -> Bool {
        let convertedUrl = convertGoogleDriveUrl(url)
        guard let downloadUrl = URL(string: convertedUrl) else { return false }
        
        let (tempFile, response) = try await URLSession.shared.download(from: downloadUrl)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            return false
        }
        
        // Handle Google Drive virus scan warning
        if httpResponse.mimeType == "text/html" {
            let html = try String(contentsOf: tempFile)
            if html.contains("confirm=") {
                let confirmToken = html.components(separatedBy: "confirm=")[1].components(separatedBy: "&")[0]
                let confirmUrl = "\(convertedUrl)&confirm=\(confirmToken)"
                if let finalUrl = URL(string: confirmUrl) {
                    let (finalFile, finalResponse) = try await URLSession.shared.download(from: finalUrl)
                    guard let finalHttpResponse = finalResponse as? HTTPURLResponse, finalHttpResponse.statusCode == 200 else {
                        return false
                    }
                    return unzip(fileURL: finalFile)
                }
            }
            return false
        }

        return unzip(fileURL: tempFile)
    }

    func validate() -> ValidationResult {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioDir = documentsURL.appendingPathComponent("audio")
        
        // In iOS, we'd bundle phrase-list.txt as a resource
        let phraseList: [String] = {
            if let path = Bundle.main.path(forResource: "phrase-list", ofType: "txt"),
               let content = try? String(contentsOfFile: path) {
                return content.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
            }
            return []
        }()

        var results: [ChildStatus] = []
        if let children = try? fileManager.contentsOfDirectory(at: audioDir, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) {
            for childDir in children {
                if childDir.hasDirectoryPath {
                    let existingPhrases = (try? fileManager.contentsOfDirectory(at: childDir, includingPropertiesForKeys: nil, options: .skipsHiddenFiles))?
                        .filter { $0.pathExtension == "mp3" }
                        .map { $0.deletingPathExtension().lastPathComponent } ?? []
                    
                    let existingSet = Set(existingPhrases)
                    let missing = phraseList.filter { !existingSet.contains($0) }
                    results.append(ChildStatus(name: childDir.lastPathComponent, missingPhrases: missing))
                }
            }
        }

        return ValidationResult(children: results)
    }

    private func unzip(fileURL: URL) -> Bool {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioDir = documentsURL.appendingPathComponent("audio")
        
        do {
            if fileManager.fileExists(atPath: audioDir.path) {
                try fileManager.removeItem(at: audioDir)
            }
            try fileManager.createDirectory(at: audioDir, withIntermediateDirectories: true)
            try fileManager.unzipItem(at: fileURL, to: audioDir)
            return true
        } catch {
            print("Unzip error: \(error)")
            return false
        }
    }
}
