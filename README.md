# Nana & Poppy iOS App

The **Nana & Poppy** app is a personalized iOS application designed to bring warm daily greetings and live information to grandparents using the recorded voices and photos of their grandchildren.

When Nana or Poppy press **Play**, the app generates a complete personalized announcement—including the time of day greeting, current date, current time, and real-time weather forecasts for two custom locations—stitching together voice clips from different grandchildren for each phrase and displaying full-screen photos of each grandchild while they speak.

---

## Table of Contents

- [Features](#features)
- [User Guide: Personalizing Nana & Poppy](#user-guide-personalizing-nana--poppy)
  - [Step 1: Record the Audio Clips](#step-1-record-the-audio-clips)
  - [Step 2: Complete Required Phrase List](#step-2-complete-required-phrase-list)
  - [Step 3: Add a Grandchild Photo](#step-3-add-a-grandchild-photo)
  - [Step 4: Create the `locations.json` File](#step-4-create-the-locationsjson-file)
  - [Step 5: Package the ZIP File](#step-5-package-the-zip-file)
  - [Step 6: Host Your ZIP File Online](#step-6-host-your-zip-file-online)
  - [Step 7: Sync in the App](#step-7-sync-in-the-app)
- [Developer Guide](#developer-guide)
  - [Prerequisites](#prerequisites)
  - [Building & Running](#building--running)
  - [Testing](#testing)
  - [App Store & Privacy Compliance](#app-store--privacy-compliance)
- [License](#license)

---

## Features

- **Personalized Voice Messages:** Plays audio clips of grandchildren speaking the time, date, and weather.
- **Dynamic Visuals:** Displays a **full-screen photo** of the grandchild currently speaking as the background during their audio segment.
- **Dynamic Greetings:** Automatically chooses "Good morning", "Good afternoon", "Good evening", or "Good night" based on the device clock.
- **Real-Time Weather:** Fetches live temperatures for two locations using the free Open-Meteo API (no API key required).
- **Remote Content Sync:** Securely downloads and updates voice clips and photos directly from a cloud ZIP file (e.g., Google Drive or Dropbox).
- **Modern iOS Design:** Native SwiftUI interface optimized for both iPhone and iPad screens.

---

## User Guide: Personalizing Nana & Poppy

Setting up custom recordings for your family requires no coding knowledge. Follow these 7 steps to create your personalized audio package.

---

### Step 1: Record the Audio Clips

Each grandchild needs to record a set of short individual words and phrases. When the app runs, it pieces these recordings together into full sentences.

#### Recording Tips & Recommendations

1. **Use Any Recording Device:** You can use Voice Memos on an iPhone, Voice Recorder on Android, or a computer microphone.
2. **Quiet Room:** Record in a quiet room with minimal background noise (turn off TVs, fans, and close windows).
3. **Microphone Distance:** Hold the phone or microphone about 6 to 8 inches from the child's mouth.
4. **Natural Speech:** Have the child speak clearly at a normal tone and speed.
5. **Trim Silence ("Dead Air"):** Keep each recording concise, leaving very little silent space at the start or end of the audio clip so spoken sentences flow naturally. Recommended free tools to help trim dead air:
   - **Audacity (Mac / Windows / Linux - Free & Open Source):** Has a built-in **"Truncate Silence"** feature (`Effect -> Truncate Silence`) that automatically detects and removes silent gaps across recordings.
   - **GarageBand or Apple Voice Memos (Mac / iOS - Free):** Use the visual waveform editor to drag the handle edges and crop out quiet space at the beginning and end of clips.
   - **Online Web Editors (Browser - Free):** Web tools like [AudioTrimmer](https://audiotrimmer.com) allow you to quickly trim silent ends and export directly to MP3 without installing software.
   - **Mobile Editing Apps (iOS / Android - Free):** Apps like **WavePad Audio Editor**, **Lexis Audio Editor**, or **Ferrite Recording Studio** offer auto-trimming and silence removal on smartphones.

6. **File Format:** Save or convert all audio files into **MP3 format** (`.mp3`).

---

### Step 2: Complete Required Phrase List

Each grandchild's folder must contain **all 79 MP3 files** listed below. 

> ⚠️ **Important Filename Rules:**
> - Filenames must be **all lowercase**.
> - Replace spaces with **underscores** `_` (for example, `nana_and_poppy.mp3`).
> - Files must end with `.mp3`.

> 💡 **Fixed Filenames vs. Custom Spoken Phrases:**
> Several files require fixed filenames for the software to identify them, even though the actual spoken phrase is personalized for your family:
> - **`nana_and_poppy.mp3`**: The file **must** be named `nana_and_poppy.mp3` so the software can locate it, but the child should speak whatever terms of endearment they naturally use (e.g., *"Grandma and Grandpa"*, *"Nana and Poppy"*, or *"Pop-Pop and Mimi"*).
> - **`location1.mp3` & `location2.mp3`**: The files **must** be named `location1.mp3` and `location2.mp3`, but the child speaks the actual name of the location (e.g., *"Waynesboro, Pennsylvania"* or *"Ocean City, Maryland"*).

#### 1. Core Greetings & Phrases (17 Files)

| Spoken Phrase | Exact Filename | Description / Notes |
| :--- | :--- | :--- |
| "Good" | `good.mp3` | Opening greeting word |
| "morning" | `morning.mp3` | Used for morning greetings (12:00 AM – 11:59 AM) |
| "afternoon" | `afternoon.mp3` | Used for afternoon greetings (12:00 PM – 4:59 PM) |
| "evening" | `evening.mp3` | Used for evening greetings (5:00 PM – 7:59 PM) |
| "night" | `night.mp3` | Used for night greetings (8:00 PM – 11:59 PM) |
| *(Terms of Endearment)* | `nana_and_poppy.mp3` | Named `nana_and_poppy.mp3`, but spoken as the child's terms of endearment (e.g., "Grandma and Grandpa") |
| "The time" | `the_time.mp3` | Time announcement prefix |
| "Today" | `today.mp3` | Date announcement prefix |
| "The current temperature for" | `the_current_temperature_for.mp3` | Weather announcement prefix |
| *(Primary Location Name)* | `location1.mp3` | Named `location1.mp3`, but spoken as the location name (e.g., "Waynesboro, Pennsylvania") |
| *(Secondary Location Name)* | `location2.mp3` | Named `location2.mp3`, but spoken as the location name (e.g., "Ocean City, Maryland") |
| "is" | `is.mp3` | Connecting verb |
| "and" | `and.mp3` | Connecting word |
| "degrees" | `degrees.mp3` | Weather temperature unit |
| "minus" | `minus.mp3` | Used for below-zero temperatures |
| "A M" | `am.mp3` | Morning time indicator |
| "P M" | `pm.mp3` | Afternoon/evening time indicator |


#### 2. Months of the Year (12 Files)

| Month | Exact Filename | Month | Exact Filename |
| :--- | :--- | :--- | :--- |
| January | `january.mp3` | July | `july.mp3` |
| February | `february.mp3` | August | `august.mp3` |
| March | `march.mp3` | September | `september.mp3` |
| April | `april.mp3` | October | `october.mp3` |
| May | `may.mp3` | November | `november.mp3` |
| June | `june.mp3` | December | `december.mp3` |

#### 3. Day of the Month Ordinals (21 Files)

| Ordinal | Exact Filename | Ordinal | Exact Filename |
| :--- | :--- | :--- | :--- |
| First (1st) | `first.mp3` | Twelfth (12th) | `twelfth.mp3` |
| Second (2nd) | `second.mp3` | Thirteenth (13th) | `thirteenth.mp3` |
| Third (3rd) | `third.mp3` | Fourteenth (14th) | `fourteenth.mp3` |
| Fourth (4th) | `fourth.mp3` | Fifteenth (15th) | `fifteenth.mp3` |
| Fifth (5th) | `fifth.mp3` | Sixteenth (16th) | `sixteenth.mp3` |
| Sixth (6th) | `sixth.mp3` | Seventeenth (17th) | `seventeenth.mp3` |
| Seventh (7th) | `seventh.mp3` | Eighteenth (18th) | `eighteenth.mp3` |
| Eighth (8th) | `eighth.mp3` | Nineteenth (19th) | `nineteenth.mp3` |
| Ninth (9th) | `ninth.mp3` | Twentieth (20th) | `twentieth.mp3` |
| Tenth (10th) | `tenth.mp3` | Thirtieth (30th) | `thirtieth.mp3` |
| Eleventh (11th) | `eleventh.mp3` | | |

*(Note: For days 21–29 and 31, the app automatically combines numbers like `twenty.mp3` + `first.mp3` or `thirty.mp3` + `first.mp3`.)*

#### 4. Numbers & Time Elements (29 Files)

| Number / Word | Exact Filename | Number / Word | Exact Filename |
| :--- | :--- | :--- | :--- |
| "oh" (zero for minutes) | `oh.mp3` | Fifteen (15) | `fifteen.mp3` |
| One (1) | `one.mp3` | Sixteen (16) | `sixteen.mp3` |
| Two (2) | `two.mp3` | Seventeen (17) | `seventeen.mp3` |
| Three (3) | `three.mp3` | Eighteen (18) | `eighteen.mp3` |
| Four (4) | `four.mp3` | Nineteen (19) | `nineteen.mp3` |
| Five (5) | `five.mp3` | Twenty (20) | `twenty.mp3` |
| Six (6) | `six.mp3` | Thirty (30) | `thirty.mp3` |
| Seven (7) | `seven.mp3` | Forty (40) | `forty.mp3` |
| Eight (8) | `eight.mp3` | Fifty (50) | `fifty.mp3` |
| Nine (9) | `nine.mp3` | Sixty (60) | `sixty.mp3` |
| Ten (10) | `ten.mp3` | Seventy (70) | `seventy.mp3` |
| Eleven (11) | `eleven.mp3` | Eighty (80) | `eighty.mp3` |
| Twelve (12) | `twelve.mp3` | Ninety (90) | `ninety.mp3` |
| Thirteen (13) | `thirteen.mp3` | Hundred (100) | `hundred.mp3` |
| Fourteen (14) | `fourteen.mp3` | | |

---

### Step 3: Add a Grandchild Photo

Inside each child's folder, include a photo file named **`photo.jpg`**.

- **Filename:** Must be named `photo.jpg` (lowercase).
- **Format:** JPEG image format.
- **Display:** When the app plays that grandchild's voice segment, their photo will automatically be displayed full-screen as the background.

---

### Step 4: Create the `locations.json` File

The app needs a small text file named `locations.json` to know which ZIP codes to query for weather forecasts. **Note: The values in `locations.json` must be valid 5-digit US ZIP codes only.**

1. Open a text editor (such as **Notepad** on Windows or **TextEdit** on Mac set to Plain Text mode).
2. Paste the following structure:

```json
{
  "location1": "17268",
  "location2": "21842"
}
```

3. Replace `"17268"` with the ZIP code corresponding to your `location1.mp3` recording.
4. Replace `"21842"` with the ZIP code corresponding to your `location2.mp3` recording.
5. Save the file as **`locations.json`**.

#### How to Test Your Location ZIP Code

You can test whether Open-Meteo recognizes your ZIP code before saving:

1. Open a browser and visit:  
   `https://geocoding-api.open-meteo.com/v1/search?name=YOUR_ZIP_CODE`  
   *(Example for ZIP 17268: [https://geocoding-api.open-meteo.com/v1/search?name=17268](https://geocoding-api.open-meteo.com/v1/search?name=17268))*
2. If the web page shows `"latitude"` and `"longitude"` coordinates for your location, it will work in the app.


---

### Step 5: Package the ZIP File

Organize all files into a main folder structure, then compress it into a `.zip` archive.

#### Required Folder Layout

```text
my_family_audio/
├── locations.json
├── owen/
│   ├── photo.jpg
│   ├── good.mp3
│   ├── morning.mp3
│   ├── location1.mp3
│   └── ... (all 79 mp3 files)
└── piper/
    ├── photo.jpg
    ├── good.mp3
    ├── morning.mp3
    ├── location1.mp3
    └── ... (all 79 mp3 files)
```

#### How to Create a ZIP File

- **On macOS:** Select `locations.json` and all grandchild subfolders -> Right-click -> Choose **Compress**.
- **On Windows:** Select `locations.json` and all grandchild subfolders -> Right-click -> Choose **Compress to ZIP file** (or **Send to** -> **Compressed (zipped) folder**).
- Rename the resulting file to something like `audio.zip`.

---

### Step 6: Host Your ZIP File Online

To sync the audio into the app, upload `audio.zip` to a cloud service to get a public link.

#### Using Google Drive (Recommended & Easiest)

1. Upload `audio.zip` to your **Google Drive**.
2. Right-click `audio.zip` in Google Drive and select **Share** -> **Share**.
3. Under *General access*, change the setting from *Restricted* to **Anyone with the link**.
4. Click **Copy link**.
5. Paste this standard Google Drive share link directly into the app!  
   *(The Nana & Poppy app automatically converts standard Google Drive links into direct download links.)*

#### Using Dropbox or Personal Web Servers

- **Dropbox:** Upload the file, create a share link, and make sure the link ends with `?dl=1` for a direct download.
- **Web Server:** Any direct HTTPS link (e.g. `https://yourdomain.com/audio.zip`) is fully supported.

---

### Step 7: Sync in the App

1. Launch the **Nana & Poppy** app on your iPhone or iPad.
2. Tap the **Settings** gear icon in the top right corner.
3. In the **Audio ZIP URL** field, paste your cloud link (e.g., your Google Drive link).
4. Tap **Save Settings**.
5. Tap **Sync Audio**.
6. The app will download, extract, and check your files:
   - A **green checkmark** indicates all 79 phrases are present.
   - If any audio clips are missing, a **red warning** will display the exact missing file names so you can easily record and add them.
7. Return to the main screen and tap **Play** to enjoy your personalized greeting!

---

## Developer Guide

### Prerequisites

- **macOS:** 12.0 or later.
- **Xcode:** Version 13.0 or later.
- **iOS Target:** iOS 15.0 or later.

### Building & Running

1. Clone the repository:
   ```bash
   git clone https://github.com/rlucente-retro/nana-poppy-ios.git
   ```
2. Open **`NanaPoppy.xcodeproj`** in Xcode.
3. Xcode will resolve the **ZIPFoundation** dependency automatically via Swift Package Manager.
4. Select your target device or simulator and press **Cmd + R** to run.

### Testing

Run the full unit test suite covering message generation, child selection, weather parsing, and downloader logic:

1. Open `NanaPoppy.xcodeproj` in Xcode.
2. Press **Cmd + U** to run all tests.

### App Store & Privacy Compliance

- **Privacy Manifest ([PrivacyInfo.xcprivacy](file:///Users/richardlucente/development/git/nana-poppy-ios/NanaPoppy/PrivacyInfo.xcprivacy)):** Declares required reason codes for `UserDefaults` (`CA92.1`) and local file timestamp checks (`DDA9.1`).
- **Encryption Compliance:** `ITSAppUsesNonExemptEncryption` is set to `NO` in build settings.
- **Privacy Policy:** Read our complete [PRIVACY_POLICY.md](PRIVACY_POLICY.md).

---

## Contributing

Contributions, bug reports, and feature requests are welcome. Please ensure any pull requests include corresponding unit tests.

---

## License

This project is licensed under the Apache License 2.0. See the [LICENSE](LICENSE) file for details.

