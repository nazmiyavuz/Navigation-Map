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
        let button = UIButton(type: .system)
        button.setImage(.mapButton?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleCenterLocation), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    
    var mapView: MKMapView!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
        enableLocationServices()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        centerMapOnUserLocation()
    }
    
    // MARK: - Services
    
    // MARK: - Private Functions
    
    // MARK: - Action
    
    @objc private func handleCenterLocation() {
        centerMapOnUserLocation()
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        configureMapView()
        
        searchInputView = SearchInputView()
        searchInputView.delegate = self
        view.addSubview(searchInputView)
        searchInputView.anchor(left: view.leftAnchor, bottom: view.bottomAnchor,
                               right: view.rightAnchor,
                               paddingLeft: 0, paddingBottom: -(view.frame.height - 88), paddingRight: 0,
                               height: view.frame.height)
        
        view.addSubview(centerMapButton)
        centerMapButton.anchor(bottom: searchInputView.topAnchor, right: view.rightAnchor,
                               paddingBottom: 16, paddingRight: 16, width: 50, height: 50)
    }
    
    private func configureMapView() {
        mapView = MKMapView()
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        
        view.addSubview(mapView)
        mapView.fillSuperview()
    }
    
}

// MARK: - SearchInputViewDelegate

extension MapController: SearchInputViewDelegate {
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
            UIView.animate(withDuration: 0.25) {
                self.centerMapButton.alpha = 1
            }
        }
    }
}

// MARK: - MApKit Helper Functions

extension MapController {
    
    private func centerMapOnUserLocation() {
        guard let coordinates = locationManager.location?.coordinate else { return }
        let coordinateRegion = MKCoordinateRegion(center: coordinates, latitudinalMeters: 2000, longitudinalMeters: 2000)
        mapView.setRegion(coordinateRegion, animated: true)
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
