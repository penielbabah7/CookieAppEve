//
//  LocationManager.swift
//  CookieApp
//
//  Created by Peniel Babah on 11/22/24.
//

import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var address: String = ""
    @Published var errorMessage: String?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            DispatchQueue.main.async {
                self.userLocation = location.coordinate
                self.reverseGeocode(location: location)
            }
            manager.stopUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.errorMessage = "Failed to get location: \(error.localizedDescription)"
        }
    }

    private func reverseGeocode(location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let placemark = placemarks?.first {
                let formattedAddress = [
                    placemark.subThoroughfare ?? "",
                    placemark.thoroughfare ?? "",
                    placemark.locality ?? "",
                    placemark.administrativeArea ?? "",
                    placemark.postalCode ?? "",
                    placemark.country ?? ""
                ].joined(separator: ", ")
                DispatchQueue.main.async {
                    self.address = formattedAddress
                }
            } else if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to reverse geocode: \(error.localizedDescription)"
                }
            }
        }
    }
}

