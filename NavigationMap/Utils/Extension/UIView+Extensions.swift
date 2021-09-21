import UIKit

// MARK: - UIView Anchor

extension UIView {
    
    // MARK: anchor
    func anchor(top: NSLayoutYAxisAnchor? = nil,
                left: NSLayoutXAxisAnchor? = nil,
                bottom: NSLayoutYAxisAnchor? = nil,
                right: NSLayoutXAxisAnchor? = nil,
                paddingTop: CGFloat = 0,
                paddingLeft: CGFloat = 0,
                paddingBottom: CGFloat = 0,
                paddingRight: CGFloat = 0,
                width: CGFloat? = nil,
                height: CGFloat? = nil,
                isActive: Bool = true) {

        translatesAutoresizingMaskIntoConstraints = false

        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = isActive
        }

        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = isActive
        }

        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = isActive
        }

        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = isActive
        }

        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = isActive
        }

        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = isActive
        }
    }

    // MARK: center
    func center(inView view: UIView,
                yConstant: CGFloat? = 0,
                width: CGFloat? = nil,
                height: CGFloat? = nil,
                isActive: Bool = true) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = isActive
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: yConstant!).isActive = isActive

        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = isActive
        }

        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = isActive
        }
    }

    // MARK: centerX
    func centerX(inView view: UIView,
                 topAnchor: NSLayoutYAxisAnchor? = nil,
                 bottomAnchor: NSLayoutYAxisAnchor? = nil,
                 paddingTop: CGFloat = 0,
                 paddingBottom: CGFloat = 0,
                 width: CGFloat? = nil,
                 height: CGFloat? = nil,
                 isActive: Bool = true) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = isActive

        if let topAnchor = topAnchor {
            self.topAnchor.constraint(equalTo: topAnchor, constant: paddingTop).isActive = isActive
        }
        
        if let bottom = bottomAnchor {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = isActive
        }

        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = isActive
        }

        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = isActive
        }
    }

    // MARK: centerY
    func centerY(inView view: UIView,
                 leftAnchor: NSLayoutXAxisAnchor? = nil,
                 rightAnchor: NSLayoutXAxisAnchor? = nil,
                 paddingLeft: CGFloat = 0,
                 paddingRight: CGFloat = 0,
                 width: CGFloat? = nil,
                 height: CGFloat? = nil,
                 constant: CGFloat = 0,
                 isActive: Bool = true) {

        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant).isActive = isActive

        if let left = leftAnchor {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = isActive
        }
        
        if let right = rightAnchor {
            self.rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = isActive
        }
        
        if let width = width {
            self.widthAnchor.constraint(equalToConstant: width).isActive = isActive
        }
        
        if let height = height {
            self.heightAnchor.constraint(equalToConstant: height).isActive = isActive
        }

    }

    // MARK: setDimensions
    func setDimensions(height: CGFloat, width: CGFloat, isActive: Bool = true) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = isActive
        widthAnchor.constraint(equalToConstant: width).isActive = isActive
    }

    // MARK: setHeight
    func setHeight(_ height: CGFloat, isActive: Bool = true) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = isActive
    }

    // MARK: setWidth
    func setWidth(_ width: CGFloat, isActive: Bool = true) {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: width).isActive = isActive
    }

    // MARK: fillSuperview
    func fillSuperview(padding: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        guard let view = superview else { return }
        anchor(top: view.topAnchor,
               left: view.leftAnchor,
               bottom: view.bottomAnchor,
               right: view.rightAnchor,
               paddingTop: padding,
               paddingLeft: padding,
               paddingBottom: padding,
               paddingRight: padding)
    }
    
    // MARK: fillSuperviewSafeArea
    func fillSuperviewSafeArea(padding: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        guard let view = superview else { return }
        anchor(top: view.safeAreaLayoutGuide.topAnchor,
               left: view.safeAreaLayoutGuide.leftAnchor,
               bottom: view.safeAreaLayoutGuide.bottomAnchor,
               right: view.safeAreaLayoutGuide.rightAnchor,
               paddingTop: padding,
               paddingLeft: padding,
               paddingBottom: padding,
               paddingRight: padding)
    }

}
