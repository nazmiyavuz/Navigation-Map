//
//  LocationRequestController.swift
//  NavigationMap
//
//  Created by Nazmi Yavuz on 25.06.2021.
//

import UIKit
import CoreLocation

class LocationRequestController: UIViewController {
    
    // MARK: - UIViews
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .bluePin
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let allowedLocationLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(
            string: "Allow Location\n",
            attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 24)])
        attributedText.append(
            NSAttributedString(
                string: "Please enable location services so that we can track your movements",
                attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)]))
        label.numberOfLines = 0
        label.textAlignment = .center
        label.attributedText = attributedText
        return label
    }()
    
    private lazy var enableLocationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Enable Location", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .mainBlue
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(handleRequestLocation), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    
    var locationManager: CLLocationManager?
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Action
    @objc private func handleRequestLocation() {
        print("DEBUG: did tapped handleRequestLocation..")
        guard let locationManager = locationManager else { return }
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        view.backgroundColor = .white
        
        view.addSubview(imageView)
        imageView.centerX(inView: view, topAnchor: view.topAnchor,
                          paddingTop:  140, width: 200, height: 200)
        
        view.addSubview(allowedLocationLabel)
        allowedLocationLabel.centerX(inView: view, topAnchor: imageView.bottomAnchor,
                                     paddingTop: 32)
        allowedLocationLabel.anchor(left: view.leftAnchor, right: view.rightAnchor,
                                    paddingLeft: 32, paddingRight: 32)
        
        view.addSubview(enableLocationButton)
        enableLocationButton.anchor(top: allowedLocationLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor,
                                    paddingTop: 24, paddingLeft: 32, paddingRight: 32, height: 50)
        
    }
}
// MARK: - CLLocationManagerDelegate
extension LocationRequestController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        guard locationManager?.location != nil else {
            print("DEBUG: ERROR! FileName: \(#file), line: \(#line)"); return
        }
        
        dismiss(animated: true, completion: nil)
    }
}
