# LocationSimulator

A native iOS app (Swift / SwiftUI / MapKit / CoreLocation / SwiftData) for selecting, saving, and **simulating GPS locations** — built around what Apple's platform actually allows, with no fake promises.

```
Location Simulator                    (?)
┌─────────────────────────────────────┐
│ 🔍 Search for a city, address…      │
├──────────────────┬──────────────────┤
│ Latitude         │ Longitude        │
│ [ 25.204800 ]    │ [ 55.270800 ]    │
├──────────────────┴──────────────────┤
│                MAP                  │
│         📍 (tap to select)          │
├─────────────────────────────────────┤
│ [ Set Location ]      [ Stop ]      │
├─────────────────────────────────────┤
│ Saved Locations          [+ Save]   │
│  • Home        25.2048, 55.2708     │
│  • Office      24.7136, 46.6753     │
└─────────────────────────────────────┘
```

## The honest part first: what iOS allows

Before writing a line of code, the constraint that shapes this whole project:

| Level | What it means | Possible? | How |
|---|---|---|---|
| **1. In-app simulation** | This app treats a chosen coordinate as "current location" inside its own UI | ✅ Yes | Normal app code (`Set Location` button) |
| **2. Device simulation during development** | A real iPhone reports a simulated position through Core Location while attached to Xcode | ✅ Yes | **Xcode + GPX files** — the officially supported developer/testing mechanism. This app generates those GPX files for you |
| **3. Global GPS spoofing** | Permanently override the GPS position every app on the phone sees, with no computer attached | ❌ **No** | Not possible for a sandboxed/App Store app. Apple provides no public API for it. Anything claiming otherwise requires a jailbreak or is a scam |

**A normal iOS application cannot globally spoof the device's GPS.** Core Location has no public API to inject locations system-wide; the location stack is enforced below the app sandbox. What Apple *does* officially support is **location simulation through Xcode**: a GPX file (or a built-in preset) makes the connected device report the simulated position via Core Location while a debug session is active. In practice this affects location readings across the device until simulation is stopped (Debug > Simulate Location > *Don't Simulate Location*) or the device is restarted — but it always requires a Mac, Xcode, Developer Mode, and a development-signed build. It is a **development/testing feature**, not something an app can ship to end users.

This project therefore implements **levels 1 and 2 properly**: a full-featured location picker app, plus dynamic GPX generation and a documented Xcode workflow for real on-device simulation.

## Features

- **Set Location** — enter any latitude (−90…90) and longitude (−180…180), validated with clear error messages; `Set Location` activates in-app simulation and generates a GPX file; `Stop` ends it.
- **Search** — find cities, addresses, places, and landmarks with Apple's `MKLocalSearch`. No external API, no API key.
- **Interactive map** — MapKit (SwiftUI `Map`): pan, zoom, tap anywhere to select a coordinate (fields update automatically), marker for the selection, blue dot for the device's real (or Xcode-simulated) position.
- **Saved locations** — name, save, reuse, and delete locations, persisted locally with SwiftData.
- **GPX export** — every `Set Location` generates a valid GPX 1.1 file; export it via the share sheet (AirDrop, Files, Mail…) for use with Xcode. Sample GPX files are included in `LocationSimulator/Resources/SampleGPX/`.
- **Built-in guide** — the `?` button in the app explains the three levels above and the exact Xcode workflow.

## Requirements

- **Mac** with **Xcode 16 or later** (the project uses Xcode's folder-synchronized project format)
- **iOS 17.0+** deployment target (iPhone and iPad)
- A **free or paid Apple Developer account** (free is enough for on-device development)
- A physical iPhone for device simulation (the iOS Simulator also works — see below)

No third-party dependencies. No API keys. Nothing to configure beyond signing.

## Project structure

```
LocationSimulator/
├── LocationSimulator.xcodeproj/          # Xcode project (open this)
├── LocationSimulator/
│   ├── LocationSimulatorApp.swift        # App entry point + SwiftData container
│   ├── Models/
│   │   ├── SavedLocation.swift           # SwiftData @Model
│   │   └── CoordinateParser.swift        # Lat/lon validation & parsing
│   ├── Services/
│   │   ├── GPXGenerator.swift            # GPX 1.1 document generation + file export
│   │   ├── LocationSearchService.swift   # MKLocalSearch wrapper (async/await)
│   │   └── DeviceLocationService.swift   # CoreLocation wrapper (@Observable)
│   ├── ViewModels/
│   │   └── SimulatorViewModel.swift      # Main screen state (@Observable, @MainActor)
│   ├── Views/
│   │   ├── ContentView.swift             # Main screen
│   │   ├── SearchFieldView.swift
│   │   ├── CoordinateEntryView.swift
│   │   ├── MapPanelView.swift            # Map + tap-to-select
│   │   ├── ActionButtonsView.swift       # Set Location / Stop
│   │   ├── SimulationStatusView.swift    # Active-simulation banner + GPX export
│   │   ├── SearchResultsSheet.swift
│   │   ├── SavedLocationsSection.swift
│   │   ├── SaveLocationSheet.swift
│   │   └── HowItWorksView.swift          # In-app guide
│   ├── Resources/SampleGPX/              # Ready-made GPX files (Dubai, Riyadh)
│   └── Assets.xcassets/
├── README.md
├── LICENSE
└── .gitignore
```

## Getting started

### 1. Open the project

```bash
git clone <your-repo-url>
cd LocationSimulator
open LocationSimulator.xcodeproj
```

### 2. Configure signing

1. Select the **LocationSimulator** project in the navigator, then the **LocationSimulator** target → **Signing & Capabilities**.
2. Check **Automatically manage signing**.
3. Choose your **Team** (add your Apple ID under Xcode → Settings → Accounts if the list is empty).
4. Change the **Bundle Identifier** from `com.example.LocationSimulator` to something unique, e.g. `com.yourname.LocationSimulator`.

No certificates or provisioning profiles are committed to this repo — Xcode creates them automatically.

### 3. Connect your iPhone

1. Plug the iPhone into the Mac with a cable (after the first run, Wi-Fi debugging also works).
2. On the phone, tap **Trust This Computer** and enter the passcode.
3. In Xcode, pick your iPhone in the run-destination selector in the toolbar.

### 4. Enable Developer Mode (iOS 16+, required)

1. On the iPhone: **Settings → Privacy & Security → Developer Mode** → toggle **on**.
   (The menu item appears after Xcode has seen the device at least once.)
2. Restart the phone when prompted and confirm.

### 5. Run

Press **⌘R**. On the first run with a free account you may need to trust the developer certificate on the phone: **Settings → General → VPN & Device Management → your Apple ID → Trust**.

## Using the app

- **Type coordinates** into the Latitude/Longitude fields (e.g. `25.2048` / `55.2708`) and tap **Preview on Map**, or just tap **Set Location** directly.
- **Search** for any place; pick a result and its coordinates fill in automatically (you can still edit them by hand).
- **Tap the map** anywhere to select that point.
- **Set Location** turns the marker green, marks the coordinate as simulated inside the app, and generates a GPX file. **Stop** ends the in-app simulation.
- **Save Current** stores the selected coordinates under a name; tap a saved row to reuse it, or the trash icon to delete it.

## Simulating the location on a real iPhone (GPX + Xcode)

This is the officially supported way to make a physical iPhone report a custom GPS position:

1. In the app, choose your location and tap **Set Location**.
2. In the green banner, tap **Export GPX for Xcode** and send the `.gpx` file to your Mac (AirDrop is easiest). Or start from the samples in `LocationSimulator/Resources/SampleGPX/`.
3. In Xcode, **drag the `.gpx` file into the project navigator** (check "Add to target: LocationSimulator" — or add it anywhere in the workspace; Xcode only needs it to be part of the project to list it).
4. Run the app on your iPhone (**⌘R**) so a debug session is active.
5. In the Xcode menu bar: **Debug → Simulate Location → *your GPX file name***.
   (The same list is also available from the location arrow button in Xcode's debug bar.)
6. Verify: the blue user-location dot in the app's map jumps to the simulated coordinate. Apple Maps and other apps on the device will generally show the simulated position too while simulation is active.
7. To stop: **Debug → Simulate Location → Don't Simulate Location**, or stop the debug session (⏹). If the device seems to keep the simulated location afterwards, toggle Location Services off/on or restart the phone.

**Set a default simulated location for every run:** Product → Scheme → Edit Scheme… → Run → Options → check **Core Location: Allow Location Simulation** and pick your GPX file as **Default Location**.

**Movement along a route:** a GPX file with multiple `<wpt>` entries makes Xcode move the simulated position between waypoints; `<time>` elements control the speed (`GPXGenerator` supports multi-waypoint documents).

### On the iOS Simulator (no iPhone needed)

- **Features → Location** in the Simulator menu (City Run, Freeway Drive, Custom Location…), or
- From the terminal: `xcrun simctl location booted set 25.2048,55.2708`

## Limitations (Apple's security model)

What this project **can** do:

- Change the location shown/used **inside this app** (level 1) — on any iPhone, no computer needed.
- Make a **real iPhone report a simulated position through Core Location** while attached to an Xcode debug session (level 2), using the GPX files this app generates.

What **no** non-jailbroken iOS app can do — including this one:

- Permanently spoof GPS for other apps with no Mac attached.
- Ship location simulation to end users through the App Store.
- Alter carrier/network-based positioning, Find My, or system location services outside a development session.

The `CLLocationManager` API is read-only by design: apps *receive* locations, they never *inject* them. Xcode's simulation works because the developer tooling operates at a privileged level that apps themselves cannot reach. That boundary is the entire reason the GPX workflow exists.

## Error handling

The app validates and reports, with human-readable alerts:

- empty / malformed / out-of-range latitude and longitude
- empty search queries, no search results, and network/search failures
- denied or unavailable location permission (the app stays fully usable without it)
- GPX generation and file-writing failures

## License

MIT — see [LICENSE](LICENSE).
