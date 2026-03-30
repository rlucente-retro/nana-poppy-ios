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
            ZStack {
                if viewModel.isPlaying,
                   let childId = viewModel.currentChildId,
                   let photoURL = viewModel.photoURL(for: childId),
                   let uiImage = UIImage(contentsOfFile: photoURL.path) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .edgesIgnoringSafeArea(.all)
                } else {
                    ZStack {
                        Color(red: 245/255, green: 245/255, blue: 220/255)
                            .edgesIgnoringSafeArea(.all)
                        Image("Logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                    .edgesIgnoringSafeArea(.all)
                }
                
                VStack(spacing: 20) {
                    if let status = viewModel.status {
                        Text(status)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(10)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.play()
                    }) {
                        ZStack {
                            Circle()
                                .fill(viewModel.isPlaying ? Color.gray.opacity(0.8) : Color.blue.opacity(0.8))
                                .frame(width: 150, height: 150)
                            
                            Text(viewModel.isPlaying ? "Playing..." : "Play")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                    }
                    .disabled(viewModel.isPlaying)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Nana & Poppy")
            .navigationBarTitleDisplayMode(.inline)
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
