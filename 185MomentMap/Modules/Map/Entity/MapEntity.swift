import MapKit

enum MapDisplayType: String, CaseIterable, Identifiable {
    case standard
    case satellite
    case hybrid

    var id: String { rawValue }

    var title: String {
        switch self {
        case .standard: return "Standard"
        case .satellite: return "Satellite"
        case .hybrid: return "Hybrid"
        }
    }

    var mapType: MKMapType {
        switch self {
        case .standard: return .standard
        case .satellite: return .satellite
        case .hybrid: return .hybrid
        }
    }
}

enum MapVisualizationMode: String, CaseIterable, Identifiable {
    case pins
    case heatmap
    case route

    var id: String { rawValue }

    var title: String {
        switch self {
        case .pins: return "Pins"
        case .heatmap: return "Heat Map"
        case .route: return "Route"
        }
    }
}

struct MapOverlayData {
    var routeCoordinates: [CLLocationCoordinate2D] = []
    var heatmapCenters: [(coordinate: CLLocationCoordinate2D, intensity: Double)] = []
}
