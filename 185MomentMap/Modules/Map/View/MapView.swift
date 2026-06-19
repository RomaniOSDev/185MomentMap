import SwiftUI
import MapKit

enum MapModuleBuilder {
    @MainActor
    static func buildPresenter() -> MapPresenter {
        let router = MapRouter()
        let interactor = MapInteractor()
        let presenter = MapPresenter(interactor: interactor, router: router)
        router.onNavigateToDetail = { memory in
            presenter.onMemorySelected?(memory)
        }
        return presenter
    }
}

struct MapView: View {
    @ObservedObject var presenter: MapPresenter

    var body: some View {
        ZStack(alignment: .bottom) {
            MapRepresentable(
                memories: presenter.memories,
                mapType: presenter.mapType,
                visualizationMode: presenter.visualizationMode,
                overlayData: presenter.overlayData,
                savedRegion: presenter.savedRegion,
                focusCoordinate: presenter.focusCoordinate,
                focusRequestID: presenter.focusRequestID,
                onSelectMemory: { presenter.didSelectAnnotation(memory: $0) },
                onRegionChanged: { presenter.saveCurrentRegion($0) }
            )
            .ignoresSafeArea(edges: .bottom)

            if presenter.memories.isEmpty {
                EmptyStateView(
                    message: "No memories yet.\nAdd your first memory →",
                    actionTitle: nil,
                    action: nil
                )
                .background(AppColors.background.opacity(0.85))
            }

            if presenter.showNearbySheet {
                NearbyMemoriesSheet(items: presenter.nearbyItems) { memory in
                    presenter.showNearbySheet = false
                    presenter.didSelectAnnotation(memory: memory)
                }
                .frame(maxHeight: 220)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .shadow(color: .black.opacity(AppElevation.elevated.opacity), radius: AppElevation.elevated.radius, y: -6)
                .padding(.horizontal)
                .padding(.bottom, 8)
                .transition(.move(edge: .bottom))
            }

            if presenter.showNearMePanel {
                nearMePanel
                    .appCard()
                    .padding(.horizontal)
                    .padding(.bottom, presenter.showNearbySheet ? 240 : 12)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.35), value: presenter.showNearbySheet)
        .animation(.spring(response: 0.35), value: presenter.showNearMePanel)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Menu {
                    Button("Show All") { presenter.didTapShowAll() }
                    Divider()
                    Menu("Mood") {
                        Button("All Moods") { presenter.didSelectMoodFilter(nil) }
                        ForEach(Mood.allCases) { mood in
                            Button("\(mood.rawValue) \(mood.displayName)") {
                                presenter.didSelectMoodFilter(mood)
                            }
                        }
                    }
                    Menu("Trip") {
                        Button("All Trips") { presenter.didSelectTripFilter(nil) }
                        ForEach(presenter.trips) { trip in
                            Button(trip.name) { presenter.didSelectTripFilter(trip.id) }
                        }
                    }
                    Menu("Tag") {
                        Button("All Tags") { presenter.didSelectTagFilter(nil) }
                        ForEach(MemoryTag.allCases) { tag in
                            Button(tag.displayName) { presenter.didSelectTagFilter(tag) }
                        }
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .foregroundStyle(AppColors.secondaryAccent)
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 12) {
                    Button {
                        presenter.showNearMePanel.toggle()
                    } label: {
                        Image(systemName: "location.circle")
                            .foregroundStyle(presenter.nearMeEnabled ? AppColors.accent : AppColors.secondaryAccent)
                    }
                    .accessibilityLabel("Near me filter")

                    Button {
                        presenter.toggleNearbySheet()
                    } label: {
                        Image(systemName: "list.bullet.circle")
                            .foregroundStyle(AppColors.secondaryAccent)
                    }
                    .accessibilityLabel("Nearby list")

                    Menu {
                        ForEach(MapVisualizationMode.allCases) { mode in
                            Button(mode.title) { presenter.didChangeVisualizationMode(mode) }
                        }
                        Divider()
                        ForEach(MapDisplayType.allCases) { type in
                            Button(type.title) { presenter.didChangeMapType(type) }
                        }
                    } label: {
                        Image(systemName: "map")
                            .foregroundStyle(AppColors.secondaryAccent)
                    }
                }
            }
        }
        .onAppear { presenter.viewDidLoad() }
    }

    private var nearMePanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Near Me Filter", systemImage: "location.circle.fill")
                .font(.headline.weight(.bold))
                .foregroundStyle(AppColors.secondaryAccent)

            Toggle("Enable filter", isOn: Binding(
                get: { presenter.nearMeEnabled },
                set: { enabled in
                    presenter.updateNearMe(
                        latitude: presenter.nearMeLatitude,
                        longitude: presenter.nearMeLongitude,
                        radiusKm: presenter.nearMeRadiusKm,
                        enabled: enabled
                    )
                }
            ))
            .tint(AppColors.accent)

            HStack(spacing: 10) {
                AppTextField(placeholder: "Latitude", text: $presenter.nearMeLatitude, keyboardType: .decimalPad)
                    .onChange(of: presenter.nearMeLatitude) { _, _ in
                        presenter.updateNearMe(
                            latitude: presenter.nearMeLatitude,
                            longitude: presenter.nearMeLongitude,
                            radiusKm: presenter.nearMeRadiusKm,
                            enabled: presenter.nearMeEnabled
                        )
                    }
                AppTextField(placeholder: "Longitude", text: $presenter.nearMeLongitude, keyboardType: .decimalPad)
                    .onChange(of: presenter.nearMeLongitude) { _, _ in
                        presenter.updateNearMe(
                            latitude: presenter.nearMeLatitude,
                            longitude: presenter.nearMeLongitude,
                            radiusKm: presenter.nearMeRadiusKm,
                            enabled: presenter.nearMeEnabled
                        )
                    }
            }

            HStack {
                Text("Radius")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(AppColors.secondaryText)
                Spacer()
                Text("\(Int(presenter.nearMeRadiusKm)) km")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppColors.accent)
            }
            Slider(value: Binding(
                get: { presenter.nearMeRadiusKm },
                set: { value in
                    presenter.updateNearMe(
                        latitude: presenter.nearMeLatitude,
                        longitude: presenter.nearMeLongitude,
                        radiusKm: value,
                        enabled: presenter.nearMeEnabled
                    )
                }
            ), in: 1...100, step: 1)
            .tint(AppColors.accent)
        }
    }
}

struct MapRepresentable: UIViewRepresentable {
    let memories: [Memory]
    let mapType: MapDisplayType
    let visualizationMode: MapVisualizationMode
    let overlayData: MapOverlayData
    let savedRegion: SavedMapRegion?
    let focusCoordinate: CLLocationCoordinate2D?
    let focusRequestID: UUID
    let onSelectMemory: (Memory) -> Void
    let onRegionChanged: (SavedMapRegion) -> Void

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = false
        mapView.mapType = mapType.mapType

        if let saved = savedRegion {
            let region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: saved.centerLatitude, longitude: saved.centerLongitude),
                span: MKCoordinateSpan(latitudeDelta: saved.spanLatitude, longitudeDelta: saved.spanLongitude)
            )
            mapView.setRegion(region, animated: false)
            context.coordinator.didRestoreRegion = true
        }
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.mapType = mapType.mapType

        let existingAnnotations = mapView.annotations.filter { $0 is MemoryAnnotation }
        mapView.removeAnnotations(existingAnnotations)
        mapView.removeOverlays(mapView.overlays)

        if visualizationMode != .heatmap {
            let annotations = memories.map { MemoryAnnotation(memory: $0) }
            mapView.addAnnotations(annotations)
        }

        if visualizationMode == .heatmap {
            for item in overlayData.heatmapCenters {
                let circle = MKCircle(center: item.coordinate, radius: 800)
                mapView.addOverlay(circle)
            }
        }

        if visualizationMode == .route, overlayData.routeCoordinates.count >= 2 {
            let polyline = MKPolyline(
                coordinates: overlayData.routeCoordinates,
                count: overlayData.routeCoordinates.count
            )
            mapView.addOverlay(polyline)
            mapView.setVisibleMapRect(polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 60, left: 40, bottom: 60, right: 40), animated: true)
        }

        if let focusCoordinate, context.coordinator.lastFocusRequestID != focusRequestID {
            let region = MKCoordinateRegion(
                center: focusCoordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            mapView.setRegion(region, animated: true)
            context.coordinator.lastFocusRequestID = focusRequestID
        } else if !memories.isEmpty,
                  context.coordinator.lastFocusRequestID == nil,
                  !context.coordinator.didRestoreRegion,
                  visualizationMode != .route {
            let annotations = memories.map { MemoryAnnotation(memory: $0) }
            mapView.showAnnotations(annotations, animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onSelectMemory: onSelectMemory, onRegionChanged: onRegionChanged)
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        var onSelectMemory: (Memory) -> Void
        var onRegionChanged: (SavedMapRegion) -> Void
        var lastFocusRequestID: UUID?
        var didRestoreRegion = false
        private var regionSaveWorkItem: DispatchWorkItem?

        init(onSelectMemory: @escaping (Memory) -> Void, onRegionChanged: @escaping (SavedMapRegion) -> Void) {
            self.onSelectMemory = onSelectMemory
            self.onRegionChanged = onRegionChanged
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if let cluster = annotation as? MKClusterAnnotation {
                let view = mapView.dequeueReusableAnnotationView(withIdentifier: "cluster") as? MKMarkerAnnotationView
                    ?? MKMarkerAnnotationView(annotation: cluster, reuseIdentifier: "cluster")
                view.markerTintColor = UIColor(hex: "#02AFEF")
                view.glyphText = "\(cluster.memberAnnotations.count)"
                return view
            }

            guard let memoryAnnotation = annotation as? MemoryAnnotation else { return nil }

            let view = mapView.dequeueReusableAnnotationView(
                withIdentifier: CustomMapAnnotationView.reuseIdentifier
            ) as? CustomMapAnnotationView ?? CustomMapAnnotationView(
                annotation: annotation,
                reuseIdentifier: CustomMapAnnotationView.reuseIdentifier
            )
            view.annotation = annotation
            view.configure(with: memoryAnnotation.memory)
            return view
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let annotation = view.annotation as? MemoryAnnotation else { return }
            onSelectMemory(annotation.memory)
            mapView.deselectAnnotation(annotation, animated: true)
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let circle = overlay as? MKCircle {
                let renderer = MKCircleRenderer(circle: circle)
                renderer.fillColor = UIColor(hex: "#02AFEF").withAlphaComponent(0.25)
                renderer.strokeColor = UIColor(hex: "#02AFEF").withAlphaComponent(0.5)
                renderer.lineWidth = 1
                return renderer
            }
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = UIColor(hex: "#018CD0")
                renderer.lineWidth = 4
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }

        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            regionSaveWorkItem?.cancel()
            let work = DispatchWorkItem { [weak self] in
                let region = mapView.region
                self?.onRegionChanged(SavedMapRegion(
                    centerLatitude: region.center.latitude,
                    centerLongitude: region.center.longitude,
                    spanLatitude: region.span.latitudeDelta,
                    spanLongitude: region.span.longitudeDelta
                ))
            }
            regionSaveWorkItem = work
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: work)
        }
    }
}
