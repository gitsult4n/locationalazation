import CoreLocation
import Foundation
import MapKit

struct SearchResult: Identifiable {
    let id = UUID()
    let name: String
    let subtitle: String
    let coordinate: CLLocationCoordinate2D
}

enum LocationSearchError: LocalizedError {
    case emptyQuery
    case noResults(String)
    case failed(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .emptyQuery:
            return "Type a city, address, place name, or landmark before searching."
        case .noResults(let query):
            return "No places were found for “\(query)”. Try a different or more specific search."
        case .failed(let underlying):
            return "The search could not be completed: \(underlying.localizedDescription) Check your internet connection and try again."
        }
    }
}

/// Wraps `MKLocalSearch` (Apple Maps search — no external API or key needed).
struct LocationSearchService {
    /// Searches Apple Maps for the query. When `region` is provided the
    /// results are biased toward (but not limited to) that area.
    func search(for query: String, near region: MKCoordinateRegion?) async throws -> [SearchResult] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw LocationSearchError.emptyQuery }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = trimmed
        if let region {
            request.region = region
        }

        do {
            let response = try await MKLocalSearch(request: request).start()
            let results = response.mapItems.map { item in
                SearchResult(
                    name: item.name ?? trimmed,
                    subtitle: item.placemark.title ?? "",
                    coordinate: item.placemark.coordinate
                )
            }
            guard !results.isEmpty else { throw LocationSearchError.noResults(trimmed) }
            return results
        } catch let error as LocationSearchError {
            throw error
        } catch let error as MKError where error.code == .placemarkNotFound || error.code == .directionsNotFound {
            throw LocationSearchError.noResults(trimmed)
        } catch {
            throw LocationSearchError.failed(underlying: error)
        }
    }
}
