# Nana & Poppy iOS App

The **Nana & Poppy** app is a personalized iOS application designed to provide daily greetings and information for grandparents using the recorded voices of their grandchildren. The app plays a sequence of messages—including the current date, time, and weather for two locations—randomly selecting a different grandchild's voice for each segment of the greeting.

## Features

- **Personalized Voice Messages:** Plays audio clips of grandchildren speaking the time, date, and weather.
- **Dynamic Greeting:** Greets Nana and Poppy with "Good morning", "Afternoon", etc., based on the current time of day.
- **Real-time Weather:** Fetches and speaks the current temperature for two configurable locations using the OpenWeatherMap API.
- **Remote Content Sync:** Downloads and updates grandchild audio clips from a remotely hosted ZIP file.
- **Modern SwiftUI Interface:** A clean, reactive UI built with SwiftUI and Combine.
- **AVFoundation Audio:** Uses `AVQueuePlayer` for seamless, high-quality audio playback of message segments.
- **Dynamic Visuals:** Displays a **full-screen photo** of the grandchild currently speaking as the background while their specific audio segment is playing.

---

## Prerequisites

Before building and configuring the app, you will need:

1.  **OpenWeatherMap API Key:** A free or paid API key from [OpenWeatherMap](https://openweathermap.org/api).
2.  **Audio Hosting:** A URL pointing to a publicly accessible (or direct-download) ZIP file containing the grandchild audio clips.
3.  **Grandchild Audio Clips:** Recorded MP3 files for each phrase (see the [Audio Preparation Guide](#audio-preparation-guide) below).
4.  **Xcode:** Version 13.0 or later, running on macOS.

---

## Getting Started

### 1. Build & Install

1.  Clone the repository.
2.  Open **`NanaPoppy.xcodeproj`** in Xcode.
3.  Xcode will automatically resolve the **ZIPFoundation** dependency via Swift Package Manager.
4.  Select a target (iOS Simulator or a physical iOS device).
5.  Press **Cmd + R** to build and run.

### 2. Testing

Run the comprehensive unit test suite to verify message generation and business logic:
1.  In Xcode, select the **NanaPoppy** scheme.
2.  Press **Cmd + U** to run all tests.

---

## Configuration

Once the app is running, you must configure it via the **Settings** menu:

1.  On the main screen, tap the **Settings** (gear) icon in the top right.
2.  **OpenWeatherMap API Key:** Enter your OWM API key.
3.  **Audio ZIP URL:** Enter the direct download URL for your audio clips (e.g., `https://example.com/audio.zip`).
4.  **Save & Sync:**
    *   Tap **Save Settings** to store your configuration in `Keychain` and `UserDefaults`.
    *   Tap **Sync Audio** to download and unzip the audio clips using `ZIPFoundation`. The app will automatically update the **Location Query Strings** from the `locations.json` file included in the ZIP.
    *   The app will show the sync results, including any missing phrases for each child.

---

## Audio Preparation Guide

To fully personalize the app, you need to gather and organize audio clips for each grandchild.

### Directory Structure

The ZIP file must contain a `locations.json` file at its root, followed by a directory for each child. Each child directory should contain their specific MP3 recordings. For example:

```text
audio.zip
├── locations.json
├── owen/
│   ├── good.mp3
│   ├── morning.mp3
│   ├── location1.mp3
│   └── ...
├── piper/
│   ├── good.mp3
│   ├── morning.mp3
│   ├── location1.mp3
│   └── ...
```

### locations.json File

The `locations.json` file defines the query strings used by the weather service for the two locations recorded by the grandchildren. Its format is:

```json
{
  "location1": "Waynesboro,PA,US",
  "location2": "Ocean City,MD,US"
}
```

This ensures that the real-time weather data matches the specific locations identified in the audio clips.

### Phrase List

Each child's directory must include the following files. Filenames must match the phrase exactly (lowercase, underscores instead of spaces) and end in `.mp3`. Each directory should also include a `photo.jpg` file to be displayed when that child is speaking.

| Phrase / Filename | Description / Notes |
| :--- | :--- |
| `good` | "Good" |
| `morning`, `afternoon`, `evening`, `night` | Time of day greetings |
| `nana_and_poppy` | "Nana and Poppy" or whatever terms of endearment the grandchildren use |
| `the_time` | "The time" |
| `today` | "Today" |
| `the_current_temperature_for` | "The current temperature for" |
| `location1` | Name of their primary location (e.g., recorded as "Waynesboro") |
| `location2` | Name of their secondary location (e.g., recorded as "Ocean City") |
| `is`, `and`, `degrees`, `minus` | Connecting words |
| `am`, `pm` | AM/PM markers |
| `january` ... `december` | All 12 months |
| `first` ... `nineteenth` | Ordinal numbers for days |
| `twentieth`, `thirtieth` | Ordinal numbers for days |
| `oh` | Used for minutes (e.g., "four oh five") |
| `one` ... `twenty` | Cardinal numbers |
| `thirty`, `forty`, `fifty`, `sixty` | Cardinal numbers |
| `seventy`, `eighty`, `ninety`, `hundred` | Cardinal numbers |

> **Note:** For a complete list of required filenames, refer to the [`phrase-list.txt`](NanaPoppy/Resources/phrase-list.txt) file.

### Recording Tips

- Record in a quiet environment.
- Use the same microphone for consistency.
- Save files as **MP3** format.
- Keep the recordings concise with minimal silence at the beginning and end.

---

## Usage

1.  Ensure you have completed the **Configuration** and **Sync Audio** steps.
2.  On the main screen, tap the **Play** button.
3.  The app will:
    - Determine the current time and fetch weather data via `WeatherService`.
    - Generate a sequence of messages via `MessageGenerator`.
    - Randomly select a child's voice for each segment via `ChildSelector`.
    - Queue and play the audio sequence using `AudioPlayer`.
    - **Dynamic Photo Display:** As each segment plays, the UI automatically updates to show the photo of the grandchild currently speaking (if a `photo.jpg` is present in their audio directory).

---

## Contributing

This is a private project, but suggestions and improvements are welcome. Please ensure any new features include corresponding unit tests.

---

## License

This project is licensed under the Apache License 2.0. See the [LICENSE](LICENSE) file for details.
