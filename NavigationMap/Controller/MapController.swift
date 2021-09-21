//
//  MapController.swift
//  NavigationMap
//
//  Created by Nazmi Yavuz on 25.06.2021.
//

import UIKit
import MapKit
import CoreLocation

class MapController: UIViewController {
    
    // MARK: - Views
    var locationManager: CLLocationManager!
    var searchInputView: SearchInputView!
    
    private lazy var centerMapButton: UIButton = {
        $0.setImage(.mapButton?.withRenderingMode(.alwaysOriginal), for: .normal)
        $0.addTarget(self, action: #selector(handleCenterLocation), for: .touchUpInside)
        return $0
    }(UIButton(type: .system))
    
    private lazy var removeOverlayButton: UIButton = {
        $0.setImage(#imageLiteral(resourceName: "baseline_clear_white_36pt_1x").withRenderingMode(.alwaysOriginal), for: .normal)
        $0.backgroundColor = .systemRed
        $0.addTarget(self, action: #selector(handleRemoveOverlays), for: .touchUpInside)
        $0.alpha = 0
        return $0
    }(UIButton(type: .system))
    
    
    // MARK: - Properties
    
    private var mapView: MKMapView!
    private var route: MKRoute?
    var selectedAnnotation: MKAnnotation?
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
        enableLocationServices()
//        centerMapOnUserLocation(shouldLoadAnnotations: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        centerMapOnUserLocation(shouldLoadAnnotations: true)
    }
    
    // MARK: - Services
    
    // MARK: - Private Functions
    
    // MARK: - Action
    
    @objc private func handleCenterLocation() {
        centerMapOnUserLocation(shouldLoadAnnotations: false)
    }
    
    @objc private func handleRemoveOverlays() {
        UIView.animate(withDuration: 0.5) {
            self.removeOverlayButton.alpha = 0
            self.centerMapButton.alpha = 1
        }
        if !mapView.overlays.isEmpty {
            self.mapView.removeOverlay(mapView.overlays[0])
            centerMapOnUserLocation(shouldLoadAnnotations: false)
        }
        
        searchInputView.enableViewInteraction(true)
        
        guard let selectedAnno = selectedAnnotation else { return }
        mapView.deselectAnnotation(selectedAnno, animated: true)
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        configureMapView()
        
        searchInputView = SearchInputView()
        searchInputView.delegate = self
        searchInputView.mapController = self
        
        view.addSubview(searchInputView)
        searchInputView.anchor(left: view.leftAnchor, bottom: view.bottomAnchor,
                               right: view.rightAnchor,
                               paddingLeft: 0, paddingBottom: -(view.frame.height - 88), paddingRight: 0,
                               height: view.frame.height)
        
        view.addSubview(centerMapButton)
        centerMapButton.anchor(bottom: searchInputView.topAnchor, right: view.rightAnchor,
                               paddingBottom: 16, paddingRight: 16, width: 50, height: 50)
        
        view.addSubview(removeOverlayButton)
        let dimension: CGFloat = 50
        removeOverlayButton.anchor(left: view.leftAnchor, bottom: searchInputView.topAnchor,
                                   paddingLeft: 16, paddingBottom: 266, width: dimension, height: dimension)
        removeOverlayButton.layer.cornerRadius = dimension / 2
    }
    
    private func configureMapView() {
        mapView = MKMapView()
        
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.userTrackingMode = .follow
        
        view.addSubview(mapView)
        mapView.fillSuperview()
    }
    
}

// MARK: - SearchCellDelegate

extension MapController: SearchCellDelegate {
    
    func getDirection(forMApItem mapItem: MKMapItem) {
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault])
    }
    
    func distanceFromUser(location: CLLocation) -> CLLocationDistance? {
        guard let userLocation = locationManager.location else {
            return nil
        }
        return userLocation.distance(from: location)
    }
}

// MARK: - SearchInputViewDelegate

extension MapController: SearchInputViewDelegate {
    
    func selectAnnotation(withMapItem mapItem: MKMapItem) {
        for annotation in mapView.annotations where annotation.title == mapItem.name {
            self.mapView.selectAnnotation(annotation, animated: true)
            self.zoomToFit(selectedAnnotation: annotation)
            self.selectedAnnotation = annotation
            UIView.animate(withDuration: 0.5) {
                self.removeOverlayButton.alpha = 1
                self.centerMapButton.alpha = 0
            }
        }
    }
    
    func addPollyline(forDestinationMapItem destinationMapItem: MKMapItem) {
        searchInputView.enableViewInteraction(false)
        
        generatePollyline(forDestinationMapItem: destinationMapItem)
    }
    
    func handleSearch(withSearchText searchText: String) {
        removeAnnotations()
        loadAnnotations(withSearchQuery: searchText)
    }
    
    func animateCenterMapButton(expansionState: SearchInputView.ExpansionState, hideButton: Bool) {
        switch expansionState {
        case .NotExpanded:
            UIView.animate(withDuration: 0.25) {
                self.centerMapButton.frame.origin.y -= 250
            }
            if hideButton {
                self.centerMapButton.alpha = 0
            } else {
                self.centerMapButton.alpha = 1
            }
            
        case .PartiallyExpanded:
            if hideButton {
                self.centerMapButton.alpha = 0
            } else {
                UIView.animate(withDuration: 0.25) {
                    self.centerMapButton.frame.origin.y += 250
                }
            }
                
        case .FullyExpanded:
            if !hideButton {
                UIView.animate(withDuration: 0.25) {
                    self.centerMapButton.alpha = 1
                }
            }
        }
    }
}

// MARK: - MKMapViewDelegate

extension MapController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if let route = self.route {
            let pollyline = route.polyline
            let linRenderer = MKPolylineRenderer(overlay: pollyline)
            linRenderer.strokeColor = .systemBlue
            linRenderer.lineWidth = 3
            return linRenderer
        }
        return MKOverlayRenderer()
    }
}

// MARK: - MApKit Helper Functions

extension MapController {
    
    private func zoomToFit(selectedAnnotation: MKAnnotation?) {
        if mapView.annotations.isEmpty {
            return
        }
        
        var topLEftCoordinate = CLLocationCoordinate2D(latitude: -90, longitude: 180)
        var bottomRightCoordinate = CLLocationCoordinate2D(latitude: 90, longitude: -180)
        
        if let selectedAnnotation = selectedAnnotation {
            for annotation in mapView.annotations {
                if let userAnno = annotation as? MKUserLocation {
                    topLEftCoordinate.longitude = fmin(topLEftCoordinate.longitude, userAnno.coordinate.longitude)
                    topLEftCoordinate.latitude = fmax(topLEftCoordinate.latitude, userAnno.coordinate.latitude)
                    bottomRightCoordinate.longitude = fmax(bottomRightCoordinate.longitude, userAnno.coordinate.longitude)
                    bottomRightCoordinate.latitude = fmin(bottomRightCoordinate.latitude, userAnno.coordinate.latitude)
                }
                
                if annotation.title == selectedAnnotation.title {
                    topLEftCoordinate.longitude = fmin(topLEftCoordinate.longitude, annotation.coordinate.longitude)
                    topLEftCoordinate.latitude = fmax(topLEftCoordinate.latitude, annotation.coordinate.latitude)
                    bottomRightCoordinate.longitude = fmax(bottomRightCoordinate.longitude, annotation.coordinate.longitude)
                    bottomRightCoordinate.latitude = fmin(bottomRightCoordinate.latitude, annotation.coordinate.latitude)
                }
            }
            
            var region = MKCoordinateRegion(
                center: CLLocationCoordinate2DMake(
                    topLEftCoordinate.latitude - (topLEftCoordinate.latitude - bottomRightCoordinate.latitude) * 0.65,
                    topLEftCoordinate.longitude + (bottomRightCoordinate.longitude - topLEftCoordinate.longitude) * 0.65),
                span: MKCoordinateSpan(
                    latitudeDelta: fabs(topLEftCoordinate.latitude - bottomRightCoordinate.latitude) * 3.0,
                    longitudeDelta: fabs(bottomRightCoordinate.longitude - topLEftCoordinate.longitude) * 3.0))
            
            region = mapView.regionThatFits(region)
            mapView.setRegion(region, animated: true)
        }
    }
    
    private func generatePollyline(forDestinationMapItem destinationMapItem: MKMapItem) {
        
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = destinationMapItem
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let response = response else { return }
            self.route = response.routes[0]
            guard let pollyline = self.route?.polyline else { return }
            self.mapView.addOverlay(pollyline, level: .aboveRoads)
        }
        
    }
    
    private func centerMapOnUserLocation(shouldLoadAnnotations: Bool) {
        guard let coordinates = locationManager.location?.coordinate else { return }
        let coordinateRegion = MKCoordinateRegion(center: coordinates, latitudinalMeters: 3000, longitudinalMeters: 3000)
        mapView.setRegion(coordinateRegion, animated: true)
        
        if shouldLoadAnnotations {
            self.loadAnnotations(withSearchQuery: "Cafe")
        }
    }
    
    func searchBy(naturalLanguageQuery: String, region: MKCoordinateRegion, coordinate: CLLocationCoordinate2D,
                  completion: @escaping (_ response: MKLocalSearch.Response?, _ error: NSError?) -> ()) {
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = naturalLanguageQuery
        request.region = region
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                completion(nil, error! as NSError)
                return
            }
            completion(response, nil)
        }
    }
    
    private func removeAnnotations() {
        mapView.annotations.forEach { annotation in
            if let annotation = annotation as? MKPointAnnotation {
                mapView.removeAnnotation(annotation)
            }
//            mapView.removeAnnotation(annotation)
        }
    }
    
    private func loadAnnotations(withSearchQuery query: String) {
        guard let coordinate = locationManager.location?.coordinate else { return }
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        
        searchBy(naturalLanguageQuery: query, region: region, coordinate: coordinate) { response, error in
            response?.mapItems.forEach({ mapItem in
                let annotation = MKPointAnnotation()
                annotation.title = mapItem.name
                annotation.coordinate = mapItem.placemark.coordinate
                self.mapView.addAnnotation(annotation)
            })
            
            self.searchInputView.searchResults = response?.mapItems
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension MapController: CLLocationManagerDelegate {
    
    func enableLocationServices() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
                
        switch locationManager.authorizationStatus {
        
        case .notDetermined:
            let controller = LocationRequestController()
            controller.locationManager = self.locationManager
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true, completion: nil)
        case .restricted:
            print("DEBUG: restricted")
        case .denied:
            print("DEBUG: denied")
        case .authorizedAlways:
            print("DEBUG: authorizedAlways")
        case .authorizedWhenInUse: break
//            print("DEBUG: authorizedWhenInUse")
        @unknown default:
            print("DEBUG: default")
        }
    }
}
