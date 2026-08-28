import CoreLocation
import Foundation
import Observation

/// Reports the device's *actual* Core Location position and authorization
/// state. When Xcode simulates a location (GPX / Simulate Location), the
/// values delivered here reflect that simulation — which is exactly how you
/// verify that the simulation is working.
@Observable
final class DeviceLocationService: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    private(set) var lastKnownLocation: CLLocation?
    private(set) var locationError: String?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = manager.authorizationStatus
    }

    var isAuthorized: Bool {
        authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }

    var isDenied: Bool {
        authorizationStatus == .denied || authorizationStatus == .restricted
    }

    func requestAuthorizationIfNeeded() {
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
    }

    func startUpdating() {
        requestAuthorizationIfNeeded()
        if isAuthorized {
            manager.startUpdatingLocation()
        }
    }

    func stopUpdating() {
        manager.stopUpdatingLocation()
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if isAuthorized {
            locationError = nil
            manager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            lastKnownLocation = location
            locationError = nil
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard let clError = error as? CLError else {
            locationError = error.localizedDescription
            return
        }
        switch clError.code {
        case .denied:
            locationError = "Location access is denied. Enable it in Settings > Privacy & Security > Location Services if you want to see your real position."
        case .locationUnknown:
            // Transient: Core Location keeps trying on its own.
            break
        default:
            locationError = clError.localizedDescription
        }
    }
}
