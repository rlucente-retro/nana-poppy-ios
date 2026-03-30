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
        if !url.contains("drive.google.com") && !url.contains("docs.google.com") { return url }
        
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
        
        var (tempFile, response) = try await URLSession.shared.download(from: downloadUrl)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            return false
        }
        
        // Handle Google Drive virus scan warning
        if let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type"), contentType.contains("text/html") {
            let html = try String(contentsOf: tempFile)
            
            // More robust confirmation token extraction using regex
            let pattern = "confirm=([0-9a-zA-Z_-]+)"
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)) {
                let tokenRange = match.range(at: 1)
                if let swiftRange = Range(tokenRange, in: html) {
                    let confirmToken = String(html[swiftRange])
                    let confirmUrl = "\(convertedUrl)&confirm=\(confirmToken)"
                    if let finalUrl = URL(string: confirmUrl) {
                        let (finalFile, finalResponse) = try await URLSession.shared.download(from: finalUrl)
                        guard let finalHttpResponse = finalResponse as? HTTPURLResponse, finalHttpResponse.statusCode == 200 else {
                            return false
                        }
                        tempFile = finalFile
                    }
                }
            } else {
                return false
            }
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
                // Check if it's a directory
                var isDir: ObjCBool = false
                if fileManager.fileExists(atPath: childDir.path, isDirectory: &isDir), isDir.boolValue {
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
        
        // ZIPFoundation performs best when the file has a .zip extension
        let tempZipURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".zip")
        
        do {
            if fileManager.fileExists(atPath: tempZipURL.path) {
                try fileManager.removeItem(at: tempZipURL)
            }
            try fileManager.moveItem(at: fileURL, to: tempZipURL)
            
            // Clean slate for the audio directory
            if fileManager.fileExists(atPath: audioDir.path) {
                try fileManager.removeItem(at: audioDir)
            }
            try fileManager.createDirectory(at: audioDir, withIntermediateDirectories: true)
            
            // Unzip the new content into the audio folder
            try fileManager.unzipItem(at: tempZipURL, to: audioDir)
            
            // Cleanup the temporary zip
            try? fileManager.removeItem(at: tempZipURL)
            
            // Handle optional wrapper directory (e.g., if zipped as a folder)
            handleWrapperDirectory(at: audioDir)
            
            return true
        } catch {
            print("Unzip error: \(error.localizedDescription)")
            try? fileManager.removeItem(at: tempZipURL)
            return false
        }
    }

    private func handleWrapperDirectory(at audioDir: URL) {
        let fileManager = FileManager.default
        do {
            let contents = try fileManager.contentsOfDirectory(at: audioDir, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            
            // Filter out __MACOSX and other hidden files if present
            let realItems = contents.filter { 
                !$0.lastPathComponent.contains("__MACOSX") && 
                !$0.lastPathComponent.hasPrefix(".")
            }
            
            if realItems.count == 1, let firstItem = realItems.first {
                var isDir: ObjCBool = false
                if fileManager.fileExists(atPath: firstItem.path, isDirectory: &isDir), isDir.boolValue {
                    // We have a wrapper directory, move its contents up
                    let subItems = try fileManager.contentsOfDirectory(at: firstItem, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                    for subItem in subItems {
                        let dest = audioDir.appendingPathComponent(subItem.lastPathComponent)
                        if fileManager.fileExists(atPath: dest.path) {
                            try fileManager.removeItem(at: dest)
                        }
                        try fileManager.moveItem(at: subItem, to: dest)
                    }
                    try fileManager.removeItem(at: firstItem)
                }
            }
        } catch {
            print("Error handling wrapper directory: \(error)")
        }
    }
}
