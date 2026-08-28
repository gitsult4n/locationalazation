import CoreLocation
import SwiftUI

struct CoordinateEntryView: View {
    @Bindable var viewModel: SimulatorViewModel
    var locationService: DeviceLocationService

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                labeledField(
                    title: "Latitude",
                    prompt: "25.2048",
                    footnote: "-90 to 90",
                    text: $viewModel.latitudeText
                )
                labeledField(
                    title: "Longitude",
                    prompt: "55.2708",
                    footnote: "-180 to 180",
                    text: $viewModel.longitudeText
                )
            }

            HStack {
                Button {
                    viewModel.applyTypedCoordinates()
                } label: {
                    Label("Preview on Map", systemImage: "mappin.and.ellipse")
                }
                .buttonStyle(.bordered)

                Spacer()

                Button {
                    useCurrentLocation()
                } label: {
                    Label("My Location", systemImage: "location.fill")
                }
                .buttonStyle(.bordered)
            }
            .font(.subheadline)

            if let coordinate = viewModel.selectedCoordinate {
                HStack(spacing: 6) {
                    Image(systemName: "scope")
                    Text("Selected: \(SimulatorViewModel.format(coordinate))")
                        .monospacedDigit()
                    if let name = viewModel.selectedLocationName {
                        Text("· \(name)")
                            .lineLimit(1)
                    }
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
        }
    }

    private func labeledField(
        title: String,
        prompt: String,
        footnote: String,
        text: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline.weight(.semibold))
            TextField(prompt, text: text)
                .keyboardType(.numbersAndPunctuation)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .monospacedDigit()
                .padding(10)
                .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 10))
                .onSubmit {
                    viewModel.applyTypedCoordinates()
                }
            Text(footnote)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
    }

    private func useCurrentLocation() {
        if let location = locationService.lastKnownLocation {
            viewModel.select(coordinate: location.coordinate, name: "My Location")
        } else if locationService.isDenied {
            viewModel.activeError = AppError(
                title: "Location Access Denied",
                message: "Allow location access in Settings > Privacy & Security > Location Services > LocationSimulator to use your real position."
            )
        } else {
            locationService.startUpdating()
            viewModel.activeError = AppError(
                title: "Locating…",
                message: "Your position isn't available yet. Make sure location access is allowed, wait a moment, and try again."
            )
        }
    }
}

#Preview {
    CoordinateEntryView(viewModel: SimulatorViewModel(), locationService: DeviceLocationService())
        .padding()
}
