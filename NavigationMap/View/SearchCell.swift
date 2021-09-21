//
//  SearchCell.swift
//  NavigationMap
//
//  Created by Nazmi Yavuz on 25.06.2021.
//

import UIKit
import MapKit

protocol SearchCellDelegate {
    func distanceFromUser(location: CLLocation) -> CLLocationDistance?
    func getDirection(forMApItem mapItem: MKMapItem)
}

class SearchCell: UITableViewCell {
    
    // MARK: - UIViews
    
    lazy var directionButton: UIButton = {
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .directionsGreen
        $0.setTitle("Go", for: .normal)
        $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        $0.addTarget(self, action: #selector(handleGetDirection), for: .touchUpInside)
        $0.layer.cornerRadius = 5
        $0.alpha = 0
        return $0
    }(UIButton(type: .system))
    
    private lazy var imageContainerView: UIView = {
        $0.backgroundColor = .mainPink
        $0.addSubview(locationImageView)
        locationImageView.center(inView: $0)
        locationImageView.setDimensions(height: 20, width: 20)
        return $0
    }(UIView())
    
    private let locationImageView: UIImageView = {
        $0.image = #imageLiteral(resourceName: "baseline_location_on_white_24pt_3x")
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
        $0.backgroundColor = .mainPink
        return $0
    }(UIImageView())
    
    private let locationTitleLabel: UILabel = {
        $0.font = UIFont.boldSystemFont(ofSize: 16)
        return $0
    }(UILabel())
    
    private let locationDistanceLabel: UILabel = {
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = .secondaryLabel
        return $0
    }(UILabel())
    
    // MARK: - Properties
    
    var delegate: SearchCellDelegate?
    
    var mapItem: MKMapItem? {
        didSet {
            configureCell()
        }
    }
    
    // MARK: - LifeCycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        addSubview(imageContainerView)
        let dimension: CGFloat = 40
        imageContainerView.centerY(inView: self,leftAnchor: leftAnchor, paddingLeft: 8, width: dimension, height: dimension)
        imageContainerView.layer.cornerRadius = dimension / 2
        
        addSubview(locationTitleLabel)
        locationTitleLabel.anchor(top: imageContainerView.topAnchor, left: imageContainerView.rightAnchor, paddingLeft: 8)
        
        addSubview(locationDistanceLabel)
        locationDistanceLabel.anchor(left: imageContainerView.rightAnchor, bottom: imageContainerView.bottomAnchor, paddingLeft: 8)
        
        contentView.addSubview(directionButton)
        directionButton.centerY(inView: self, rightAnchor: rightAnchor, paddingRight: 8, width: 50, height: 50)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Functions
    
    // MARK: - Button Actions
    
    @objc private func handleGetDirection() {
        guard let mapItem = self.mapItem else { return }
        delegate?.getDirection(forMApItem: mapItem)
    }
    
    // MARK: - Helpers of User Interface
    
    func animateButtonIn() {
        directionButton.transform = CGAffineTransform(scaleX: 0.25, y: 0.25)
        UIView.animate(withDuration: 2, delay: 0, usingSpringWithDamping: 1,
                       initialSpringVelocity: 0, options: .curveEaseInOut) {
            self.directionButton.alpha = 1
            self.directionButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        } completion: { _ in
            self.directionButton.transform = .identity
        }

    }
    
    private func configureCell() {
        locationTitleLabel.text = mapItem?.name
        
        let distanceFormatter = MKDistanceFormatter()
        distanceFormatter.unitStyle = .abbreviated
        
        guard let mapItemLocation = mapItem?.placemark.location else { return }
        guard let distanceFromUser = delegate?.distanceFromUser(location: mapItemLocation) else { return }
        let distanceAsString = distanceFormatter.string(fromDistance: distanceFromUser)
        
        locationDistanceLabel.text = distanceAsString
    }
}
