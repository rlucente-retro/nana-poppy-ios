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
    private var onSegmentChange: ((String) -> Unit)?
    private var segments: [(childId: String, words: [String])] = []
    private var currentSegmentIndex = 0

    func playPlaylist(segments: [(childId: String, words: [String])], 
                      onSegmentChange: @escaping (String) -> Unit,
                      onComplete: @escaping () -> Unit) {
        self.segments = segments
        self.onSegmentChange = onSegmentChange
        self.onComplete = onComplete
        self.currentSegmentIndex = 0
        
        playNextSegment()
    }
    
    private func playNextSegment() {
        guard currentSegmentIndex < segments.count else {
            onComplete?()
            cleanup()
            return
        }
        
        let segment = segments[currentSegmentIndex]
        onSegmentChange?(segment.childId)
        
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioDir = documentsURL.appendingPathComponent("audio")
        
        var items: [AVPlayerItem] = []
        for word in segment.words {
            let fileURL = audioDir.appendingPathComponent("\(segment.childId)/\(word).mp3")
            if fileManager.fileExists(atPath: fileURL.path) {
                items.append(AVPlayerItem(url: fileURL))
            }
        }
        
        guard !items.isEmpty else {
            currentSegmentIndex += 1
            playNextSegment()
            return
        }
        
        player = AVQueuePlayer(items: items)
        
        // Observe only the last item of the CURRENT segment
        NotificationCenter.default.addObserver(self, selector: #selector(segmentDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: items.last)
        
        player?.play()
    }
    
    @objc private func segmentDidFinishPlaying(notification: Notification) {
        // Remove observer for the item that just finished
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: notification.object)
        
        currentSegmentIndex += 1
        playNextSegment()
    }
    
    private func cleanup() {
        onComplete = nil
        onSegmentChange = nil
        player = nil
        segments = []
    }
}

typealias Unit = Void
