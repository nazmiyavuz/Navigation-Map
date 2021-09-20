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
}

class SearchCell: UITableViewCell {
    
    // MARK: - UIViews
    
    lazy var imageContainerView: UIView = {
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Functions
    
    // MARK: - Button Actions
    
    // MARK: - Helpers of User Interface
    
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
