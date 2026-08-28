import CoreLocation
import MapKit
import SwiftUI

/// Interactive MapKit map: pan/zoom freely, tap anywhere to select a new
/// coordinate, and see the selected + simulated positions as markers.
struct MapPanelView: View {
    @Bindable var viewModel: SimulatorViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            MapReader { proxy in
                Map(position: $viewModel.cameraPosition) {
                    if let coordinate = viewModel.selectedCoordinate {
                        Annotation(
                            viewModel.selectedLocationName ?? "Selected",
                            coordinate: coordinate
                        ) {
                            pin(color: viewModel.isSimulating ? .green : .red)
                        }
                    }
                    // The system blue dot: the device's *real* position (or the
                    // Xcode-simulated one during a debug session).
                    UserAnnotation()
                }
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                    MapScaleView()
                }
                .onMapCameraChange { context in
                    viewModel.visibleRegion = context.region
                }
                .onTapGesture { screenPoint in
                    if let coordinate = proxy.convert(screenPoint, from: .local) {
                        viewModel.handleMapTap(coordinate)
                    }
                }
            }
            .frame(height: 320)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Text("Tap anywhere on the map to select a new location.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func pin(color: Color) -> some View {
        VStack(spacing: 0) {
            Image(systemName: "mappin.circle.fill")
                .font(.title)
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white, color)
            Image(systemName: "arrowtriangle.down.fill")
                .font(.caption2)
                .foregroundStyle(color)
                .offset(y: -4)
        }
        .shadow(radius: 2)
    }
}

#Preview {
    MapPanelView(viewModel: SimulatorViewModel())
        .padding()
}
