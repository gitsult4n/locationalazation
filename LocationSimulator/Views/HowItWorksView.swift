import SwiftUI

/// In-app guide that explains — honestly — what location simulation can and
/// cannot do on iOS, and how to use the exported GPX files with Xcode.
struct HowItWorksView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    section(
                        icon: "iphone",
                        iconColor: .green,
                        title: "1. In-app simulation (always available)",
                        body: "Tapping “Set Location” makes this app treat your chosen coordinate as the current position: the marker turns green and the coordinate is shown as the simulated location. This affects only LocationSimulator itself — it is what any sandboxed App Store app is allowed to do."
                    )

                    section(
                        icon: "hammer",
                        iconColor: .blue,
                        title: "2. Device simulation via Xcode + GPX (developer feature)",
                        body: "Apple's supported way to simulate a location on a real iPhone is through Xcode. Export the generated GPX file, add it to the Xcode project, run the app on your iPhone from Xcode, then choose Debug > Simulate Location > <your file>. While the debug session is running, Core Location reports the simulated position — the blue “user location” dot on this app's map will jump to it, and in practice other apps on the device typically see it too until the simulation is stopped or the device restarts. This requires a Mac with Xcode, a cable/Wi-Fi connection, Developer Mode enabled, and a development-signed build."
                    )

                    section(
                        icon: "xmark.shield",
                        iconColor: .red,
                        title: "3. Global GPS spoofing (not possible)",
                        body: "A normal iOS app cannot override the GPS position that other apps or the system receive. Apple provides no public API for it, and apps claiming to do this without a computer either require a jailbreak or do not work as advertised. This app does not pretend otherwise."
                    )

                    Divider()

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Using a GPX file with Xcode")
                            .font(.headline)
                        stepList([
                            "Pick a location here and tap “Set Location”.",
                            "Tap “Export GPX for Xcode” and send the file to your Mac (AirDrop, Files, etc.).",
                            "Drag the .gpx file into the Xcode project navigator and add it to the LocationSimulator target.",
                            "Connect your iPhone, select it as the run destination, and press Run (⌘R).",
                            "In Xcode's menu bar choose Debug > Simulate Location and pick your GPX file.",
                            "Watch the blue user-location dot on this app's map move to the simulated position.",
                            "To stop: Debug > Simulate Location > Don't Simulate Location, or stop the debug session. Restart the device if the location seems to stick."
                        ])
                    }

                    Text("Full step-by-step instructions, including Developer Mode and signing setup, are in the project's README.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
            .navigationTitle("How It Works")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func section(icon: String, iconColor: Color, title: String, body: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(iconColor)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                Text(body)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func stepList(_ steps: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 10) {
                    Text("\(index + 1)")
                        .font(.caption.bold())
                        .frame(width: 22, height: 22)
                        .background(Circle().fill(.tint.opacity(0.15)))
                    Text(step)
                        .font(.subheadline)
                }
            }
        }
    }
}

#Preview {
    HowItWorksView()
}
