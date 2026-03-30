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
import AVFoundation

class AudioPlayer: NSObject {
    private var player: AVQueuePlayer?
    private var playerItems: [AVPlayerItem] = []
    private var onComplete: (() -> Unit)?

    func playPlaylist(segments: [(childId: String, words: [String])], onComplete: @escaping () -> Unit) {
        self.onComplete = onComplete
        
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioDir = documentsURL.appendingPathComponent("audio")
        
        var items: [AVPlayerItem] = []
        for segment in segments {
            for word in segment.words {
                let fileURL = audioDir.appendingPathComponent("\(segment.childId)/\(word).mp3")
                if fileManager.fileExists(atPath: fileURL.path) {
                    items.append(AVPlayerItem(url: fileURL))
                }
            }
        }
        
        guard !items.isEmpty else {
            onComplete()
            return
        }
        
        player = AVQueuePlayer(items: items)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: items.last)
        
        player?.play()
    }
    
    @objc private func playerDidFinishPlaying() {
        onComplete?()
        onComplete = nil
    }
}

typealias Unit = Void
