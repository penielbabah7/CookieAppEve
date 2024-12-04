//
//  AddressSearchHelper.swift
//  CookieApp
//
//  Created by Peniel Babah on 11/22/24.
//

import Combine
import MapKit
import CoreLocation

// AddressSuggestion model to hold suggestion details
struct AddressSuggestion: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
}

// AddressSearchHelper class to handle address suggestions and zip-based lookups
class AddressSearchHelper: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var queryFragment: String = "" // User's search query
    @Published var suggestions: [AddressSuggestion] = [] // Address suggestions

    private var completer: MKLocalSearchCompleter
    private var cancellable: AnyCancellable?
    private var geocoder = CLGeocoder() // Used for reverse geocoding (zip -> city/state)

    override init() {
        self.completer = MKLocalSearchCompleter()
        super.init()
        self.completer.delegate = self

        // Observe the queryFragment changes
        cancellable = $queryFragment
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main) // Add debounce to reduce API calls
            .sink { [weak self] query in
                self?.updateSearchQuery(query)
            }
    }

    // MARK: - Update Search Suggestions
    func updateSearchQuery(_ query: String) {
        guard !query.isEmpty else {
            self.suggestions = []
            return
        }
        completer.queryFragment = query
    }

    // MARK: - Fetch Address by Zip Code
    func fetchAddressByZipCode(zipCode: String, completion: @escaping (String?, String?, String?) -> Void) {
        geocoder.geocodeAddressString(zipCode) { placemarks, error in
            guard let placemark = placemarks?.first else {
                completion(nil, nil, nil)
                return
            }
            let city = placemark.locality
            let state = placemark.administrativeArea
            let zip = placemark.postalCode
            completion(city, state, zip)
        }
    }

    // MARK: - Filter Suggestions with Constraints
    func updateSuggestionsWithConstraints(city: String, state: String, zipCode: String) {
        guard !queryFragment.isEmpty else {
            self.suggestions = []
            return
        }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "\(queryFragment), \(city), \(state) \(zipCode)"
        let search = MKLocalSearch(request: request)

        search.start { [weak self] response, error in
            guard let mapItems = response?.mapItems else { return }
            DispatchQueue.main.async {
                self?.suggestions = mapItems.compactMap {
                    guard let title = $0.placemark.name,
                          let subtitle = $0.placemark.title else { return nil }
                    return AddressSuggestion(title: title, subtitle: subtitle)
                }
            }
        }
    }

    // MARK: - MKLocalSearchCompleterDelegate
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.suggestions = completer.results.map { result in
            AddressSuggestion(title: result.title, subtitle: result.subtitle)
        }
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error in search completer: \(error.localizedDescription)")
    }
}
