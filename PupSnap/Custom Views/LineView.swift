//
//  LineView.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/4/24.
//

import UIKit

class LineView: UIView {
    
    /// A computed property that casts the view's backing layer to type CAShapeLayer for convenience.
    var shapeLayer: CAShapeLayer? {
            return self.layer as? CAShapeLayer
        }
    
    /// This declaration causes the  LineView's backing layer to be a CAShapeLayer
    override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }
    
    /// If the view's bounds change, update our layer's path
    override var bounds: CGRect {
        didSet {
            createPath()
        }
    }
    
    /// When we get added to a view, set up our shape layer's properties.
    override func didMoveToSuperview() {
        shapeLayer?.strokeColor = UIColor.black.cgColor
        shapeLayer?.fillColor = UIColor.clear.cgColor
        shapeLayer?.lineWidth = 2
    }
    
    /// Start and end points of the line
    var startPoint: CGPoint = .zero {
        didSet {
            createPath()
        }
    }
    var endPoint: CGPoint = .zero {
        didSet {
            createPath()
        }
    }
    
    /// Build the path for our shape layer and install it.
    func createPath() {
        let path = UIBezierPath()
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        shapeLayer?.path = path.cgPath
    }
    /// Method to set start and end points
    func setPoints(start: CGPoint, end: CGPoint) {
        self.startPoint = start
        self.endPoint = end
    }
    
}
