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

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MainViewModel()
    @State private var showingSettings = false

    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                Spacer()
                
                Button(action: {
                    viewModel.play()
                }) {
                    ZStack {
                        Circle()
                            .fill(viewModel.isPlaying ? Color.gray : Color.blue)
                            .frame(width: 200, height: 200)
                        
                        Text(viewModel.isPlaying ? "Playing..." : "Play")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    }
                }
                .disabled(viewModel.isPlaying)
                
                if let status = viewModel.status {
                    Text(status)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Nana & Poppy")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
