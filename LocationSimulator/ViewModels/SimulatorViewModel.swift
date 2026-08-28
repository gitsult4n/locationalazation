import CoreLocation
import MapKit
import Observation
import SwiftUI

struct AppError: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

@MainActor
@Observable
final class SimulatorViewModel {
    // MARK: - Coordinate entry

    var latitudeText: String
    var longitudeText: String

    // MARK: - Map state

    var cameraPosition: MapCameraPosition
    private(set) var selectedCoordinate: CLLocationCoordinate2D?
    private(set) var selectedLocationName: String?
    var visibleRegion: MKCoordinateRegion?

    // MARK: - Simulation state (in-app)

    private(set) var simulatedCoordinate: CLLocationCoordinate2D?
    private(set) var simulatedLocationName: String?
    private(set) var gpxFileURL: URL?

    var isSimulating: Bool { simulatedCoordinate != nil }

    // MARK: - Search state

    var searchQuery = ""
    private(set) var searchResults: [SearchResult] = []
    private(set) var isSearching = false
    var isShowingSearchResults = false

    // MARK: - Errors

    var activeError: AppError?

    private let searchService = LocationSearchService()

    init() {
        // Default to Dubai (25.2048, 55.2708) — matches the requested example.
        let initial = CLLocationCoordinate2D(latitude: 25.2048, longitude: 55.2708)
        latitudeText = Self.format(initial.latitude)
        longitudeText = Self.format(initial.longitude)
        selectedCoordinate = initial
        cameraPosition = .region(
            MKCoordinateRegion(
                center: initial,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        )
    }

    // MARK: - Coordinate input

    /// Validates the typed latitude/longitude and moves the selection there.
    /// Returns `false` (and sets `activeError`) when the input is invalid.
    @discardableResult
    func applyTypedCoordinates() -> Bool {
        do {
            let coordinate = try CoordinateParser.parse(latitude: latitudeText, longitude: longitudeText)
            select(coordinate: coordinate, name: nil, recenter: true)
            return true
        } catch {
            activeError = AppError(title: "Invalid Coordinates", message: error.localizedDescription)
            return false
        }
    }

    func select(coordinate: CLLocationCoordinate2D, name: String?, recenter: Bool = true) {
        selectedCoordinate = coordinate
        selectedLocationName = name
        latitudeText = Self.format(coordinate.latitude)
        longitudeText = Self.format(coordinate.longitude)
        if recenter {
            withAnimation(.easeInOut) {
                cameraPosition = .region(
                    MKCoordinateRegion(
                        center: coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                )
            }
        }
    }

    func handleMapTap(_ coordinate: CLLocationCoordinate2D) {
        select(coordinate: coordinate, name: nil, recenter: false)
    }

    // MARK: - Simulation

    /// Activates the in-app simulation for the selected coordinate and
    /// generates a GPX file for Xcode-based device simulation.
    func setLocation() {
        guard applyTypedCoordinates(), let coordinate = selectedCoordinate else { return }
        let name = selectedLocationName ?? "Custom Location"
        do {
            gpxFileURL = try GPXGenerator.writeFile(for: coordinate, name: name)
            simulatedCoordinate = coordinate
            simulatedLocationName = name
        } catch {
            simulatedCoordinate = nil
            simulatedLocationName = nil
            gpxFileURL = nil
            activeError = AppError(title: "GPX Generation Failed", message: error.localizedDescription)
        }
    }

    func stopSimulation() {
        simulatedCoordinate = nil
        simulatedLocationName = nil
        gpxFileURL = nil
    }

    // MARK: - Search

    func runSearch() async {
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            activeError = AppError(
                title: "Empty Search",
                message: LocationSearchError.emptyQuery.localizedDescription
            )
            return
        }
        isSearching = true
        defer { isSearching = false }
        do {
            searchResults = try await searchService.search(for: query, near: visibleRegion)
            isShowingSearchResults = true
        } catch {
            searchResults = []
            activeError = AppError(title: "Search Failed", message: error.localizedDescription)
        }
    }

    func choose(result: SearchResult) {
        isShowingSearchResults = false
        select(coordinate: result.coordinate, name: result.name, recenter: true)
    }

    // MARK: - Formatting

    static func format(_ value: Double) -> String {
        String(format: "%.6f", locale: Locale(identifier: "en_US_POSIX"), value)
    }

    static func format(_ coordinate: CLLocationCoordinate2D) -> String {
        "\(format(coordinate.latitude)), \(format(coordinate.longitude))"
    }
}
