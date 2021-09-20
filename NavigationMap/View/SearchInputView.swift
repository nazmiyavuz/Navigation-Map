//
//  SearchInputView.swift
//  NavigationMap
//
//  Created by Nazmi Yavuz on 25.06.2021.
//

import UIKit
import MapKit

private let reuseIdentifier = "SearchCell"

protocol SearchInputViewDelegate {
    func animateCenterMapButton(expansionState: SearchInputView.ExpansionState, hideButton: Bool)
    func handleSearch(withSearchText searchText: String)
}

class SearchInputView: UIView {
    
    // MARK: - UIViews
    
    var searchBar: UISearchBar!
    
    var tableView: UITableView!
    
    private let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 4
        view.alpha = 0.8
        return view
    }()
    
    // MARK: - Properties
    
    var delegate: SearchInputViewDelegate?
    var mapController: MapController?
    
    var searchResults: [MKMapItem]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    enum ExpansionState {
        case NotExpanded
        case PartiallyExpanded
        case FullyExpanded
    }
    
    var expansionState: ExpansionState!
    
    // MARK: - LifeCycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViewComponents()
        
        expansionState = .NotExpanded
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Functions
    
    func animateInputView(targetPosition: CGFloat, completion: @escaping(Bool) -> Void) {
        UIView.animate(
            withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.frame.origin.y = targetPosition
            }, completion: completion)
    }
    
    // MARK: - Actions
    
    @objc private func handleSwipeGesture(_ sender: UISwipeGestureRecognizer) {
        
        if sender.direction == .up {
            if expansionState == .NotExpanded {
                delegate?.animateCenterMapButton(expansionState: self.expansionState, hideButton: false)
                animateInputView(targetPosition: self.frame.origin.y - 250) { (_) in
                    self.expansionState = .PartiallyExpanded
                }
            }
            
            if expansionState == .PartiallyExpanded {
                delegate?.animateCenterMapButton(expansionState: self.expansionState, hideButton: true)
                animateInputView(targetPosition: self.frame.origin.y - 400) { (_) in
                    self.expansionState = .FullyExpanded
                }
            }
            
        } else {
            
            if expansionState == .FullyExpanded {
                self.searchBar.showsCancelButton = false
                self.searchBar.endEditing(true)
                
                animateInputView(targetPosition: self.frame.origin.y + 400) { (_) in
                    self.delegate?.animateCenterMapButton(expansionState: self.expansionState, hideButton: false)
                    self.expansionState = .PartiallyExpanded
                }
            }
            
            if expansionState == .PartiallyExpanded {
                self.delegate?.animateCenterMapButton(expansionState: self.expansionState, hideButton: false)
                animateInputView(targetPosition: self.frame.origin.y + 250) { (_) in
                    self.expansionState = .NotExpanded
                }
            }
        }
        
    }
    
    // MARK: - Helpers of User Interface
    
    private func dismissOnSearch() {
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
        animateInputView(targetPosition: self.frame.origin.y + 400) { (_) in
            self.delegate?.animateCenterMapButton(expansionState: self.expansionState, hideButton: true)
            self.expansionState = .PartiallyExpanded
        }
    }
    
    private func configureViewComponents() {
        backgroundColor = .white
        
        addSubview(indicatorView)
        indicatorView.centerX(inView: self, topAnchor: topAnchor, paddingTop: 8,
                              width: 40, height: 8)
        
        configureSearchBar()
        configureTableView()
        configureGestureRecognizers()
    }
    
    private func configureSearchBar() {
        
        searchBar = UISearchBar()
        searchBar.placeholder = "Search for a place or address"
        searchBar.delegate = self
        searchBar.barStyle = .black
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        
        addSubview(searchBar)
        searchBar.anchor(top: indicatorView.bottomAnchor, left: leftAnchor,
                         right: rightAnchor, paddingTop: 4, paddingLeft: 8,
                         paddingRight: 8, height: 50)
    }
    
    private func configureTableView() {
        tableView = UITableView()
        tableView.rowHeight = 72
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(SearchCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        addSubview(tableView)
        tableView.anchor(top: searchBar.bottomAnchor, left: leftAnchor,
                         bottom: bottomAnchor, right: rightAnchor,
                         paddingTop: 8, paddingBottom: 100)
    }
    
    private func configureGestureRecognizers() {
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        
        swipeUp.direction = .up
        addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        
        swipeDown.direction = .down
        addGestureRecognizer(swipeDown)
        
    }
}

// MARK: - UISearchBarDelegate

extension SearchInputView: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        delegate?.handleSearch(withSearchText: searchText)
        
        dismissOnSearch()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        
        if expansionState == .NotExpanded {
            delegate?.animateCenterMapButton(expansionState: self.expansionState, hideButton: true)
            animateInputView(targetPosition: self.frame.origin.y - 650) { (_) in
                self.expansionState = .FullyExpanded
            }
        }
        
        if expansionState == .PartiallyExpanded {
            delegate?.animateCenterMapButton(expansionState: self.expansionState, hideButton: true)
            animateInputView(targetPosition: self.frame.origin.y - 250) { (_) in
                self.expansionState = .FullyExpanded
            }
        }
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismissOnSearch()
    }
}

// MARK: - UITableViewDataSource

extension SearchInputView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SearchCell
        
        cell.delegate = mapController
        cell.mapItem = searchResults?[indexPath.row]
        return cell
    }
        
}
