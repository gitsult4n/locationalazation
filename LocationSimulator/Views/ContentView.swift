import CoreLocation
import SwiftData
import SwiftUI

struct ContentView: View {
    @State private var viewModel = SimulatorViewModel()
    @State private var locationService = DeviceLocationService()

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SavedLocation.createdAt, order: .reverse) private var savedLocations: [SavedLocation]

    @State private var isShowingSaveSheet = false
    @State private var isShowingHelp = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    SearchFieldView(viewModel: viewModel)
                    CoordinateEntryView(viewModel: viewModel, locationService: locationService)
                    MapPanelView(viewModel: viewModel)
                    ActionButtonsView(viewModel: viewModel)

                    if viewModel.isSimulating {
                        SimulationStatusView(viewModel: viewModel)
                    }

                    if locationService.isDenied {
                        PermissionNoticeView()
                    }

                    SavedLocationsSection(
                        locations: savedLocations,
                        canSaveCurrent: viewModel.selectedCoordinate != nil,
                        onSaveCurrent: { isShowingSaveSheet = true },
                        onSelect: { location in
                            viewModel.select(coordinate: location.coordinate, name: location.name)
                        },
                        onDelete: { location in
                            modelContext.delete(location)
                        }
                    )
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Location Simulator")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingHelp = true
                    } label: {
                        Image(systemName: "questionmark.circle")
                    }
                    .accessibilityLabel("How location simulation works")
                }
            }
            .sheet(isPresented: $viewModel.isShowingSearchResults) {
                SearchResultsSheet(viewModel: viewModel)
            }
            .sheet(isPresented: $isShowingSaveSheet) {
                if let coordinate = viewModel.selectedCoordinate {
                    SaveLocationSheet(
                        coordinate: coordinate,
                        suggestedName: viewModel.selectedLocationName ?? "",
                        onSave: { name in
                            let saved = SavedLocation(
                                name: name,
                                latitude: coordinate.latitude,
                                longitude: coordinate.longitude
                            )
                            modelContext.insert(saved)
                        }
                    )
                }
            }
            .sheet(isPresented: $isShowingHelp) {
                HowItWorksView()
            }
            .alert(
                viewModel.activeError?.title ?? "Error",
                isPresented: Binding(
                    get: { viewModel.activeError != nil },
                    set: { if !$0 { viewModel.activeError = nil } }
                ),
                presenting: viewModel.activeError
            ) { _ in
                Button("OK", role: .cancel) {}
            } message: { error in
                Text(error.message)
            }
            .onAppear {
                locationService.startUpdating()
            }
        }
    }
}

/// Shown when the user has denied location access. The app remains fully
/// functional without it — the permission only powers the "real position"
/// features.
private struct PermissionNoticeView: View {
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "location.slash")
                .foregroundStyle(.orange)
            VStack(alignment: .leading, spacing: 4) {
                Text("Location access is off")
                    .font(.subheadline.weight(.semibold))
                Text("Your real position can't be shown on the map. Everything else still works. You can enable access in Settings > Privacy & Security > Location Services.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    ContentView()
        .modelContainer(for: SavedLocation.self, inMemory: true)
}
