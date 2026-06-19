import MapKit

nonisolated final class MapService {
    func geocodeAddress(_ address: String) async -> (latitude: Double, longitude: Double)? {
        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.geocodeAddressString(address)
            guard let location = placemarks.first?.location else { return nil }
            return (location.coordinate.latitude, location.coordinate.longitude)
        } catch {
            return nil
        }
    }

    func openInMaps(latitude: Double, longitude: Double, name: String) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}
