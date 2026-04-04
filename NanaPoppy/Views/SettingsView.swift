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

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showingSyncResult = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("API Configuration")) {
                    SecureField("OpenWeatherMap API Key", text: $viewModel.owmApiKey)
                    TextField("Audio ZIP URL", text: $viewModel.zipUrl)
                }
                
                Section(header: Text("Locations")) {
                    TextField("Location 1 (e.g. Waynesboro,PA,US)", text: $viewModel.location1Query)
                    TextField("Location 2 (e.g. Ocean City,MD,US)", text: $viewModel.location2Query)
                }
                
                Section {
                    Button("Save Settings") {
                        viewModel.save()
                    }
                    
                    Button(action: {
                        viewModel.sync()
                    }) {
                        if viewModel.isSyncing {
                            ProgressView()
                        } else {
                            Text("Sync Audio")
                        }
                    }
                    .disabled(viewModel.isSyncing)
                }
                
                Section(header: Text("About")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("For detailed instructions on configuring API keys, location formats, and audio resources, please visit the project repository.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        
                        Link("View Repository on GitHub", destination: URL(string: "https://github.com/rlucente-retro/nana-poppy-ios")!)
                            .font(.body)
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
            .sheet(isPresented: $showingSyncResult) {
                if let result = viewModel.syncResult {
                    SyncResultView(result: result)
                }
            }
            .onChange(of: viewModel.syncResult != nil) { newValue in
                if newValue {
                    showingSyncResult = true
                }
            }
        }
    }
}

struct SyncResultView: View {
    let result: ValidationResult
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            List {
                if result.children.isEmpty {
                    Text("No children found in the zip file.")
                } else {
                    ForEach(result.children, id: \.name) { child in
                        Section(header: Text("Child: \(child.name)")) {
                            if child.missingPhrases.isEmpty {
                                Label("All phrases present", systemImage: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            } else {
                                Label("\(child.missingPhrases.count) phrases missing", systemImage: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                Text("Missing: \(child.missingPhrases.joined(separator: ", "))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Sync Complete")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

