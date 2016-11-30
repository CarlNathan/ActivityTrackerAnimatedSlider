//
//  CircleSliderView.swift
//  SleepDeficit
//
//  Created by Carl Udren on 11/1/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import UIKit

class CircleSliderView: UIView {
    
    internal var shapeLayer = CAShapeLayer()
    internal var backgroundLayer = CAShapeLayer()
    internal let label = UILabel()
    internal let iconView = UIImageView()
    var title: String = ""
    var color = UIColor.clear
    var fraction: Double = 0.0
    var thickness: Int = 30
    var shouldAnimate: Bool = true
    internal var cgThickness: CGFloat {
        return CGFloat(thickness)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        setupLabel()
        setupIcon()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
        setupLabel()
        setupIcon()
    }
    
    internal func setup() {
        backgroundColor = UIColor.clear
        backgroundLayer.path = createBackgroundPath().cgPath
        backgroundLayer.strokeColor = UIColor.clear.cgColor
        backgroundLayer.fillColor = color.withAlphaComponent(0.4).cgColor
        backgroundLayer.fillRule = kCAFillRuleEvenOdd
        backgroundLayer.lineWidth = 0.0
        backgroundLayer.position = CGPoint(x: 0, y: 0)
        self.layer.addSublayer(backgroundLayer)
        
        
        // The Bezier path that we made needs to be converted to
        // a CGPath before it can be used on a layer.
        shapeLayer.path = createInitialPath(thickness: thickness).cgPath
        
        // apply other properties related to the path
        shapeLayer.strokeColor = UIColor.clear.cgColor
        shapeLayer.fillColor = color.cgColor
        shapeLayer.lineWidth = 0.0
        shapeLayer.position = CGPoint(x: 0, y: 0)
        
        // add the new layer to our custom view
        self.layer.addSublayer(shapeLayer)
    }
    
    func configure(thickness: Int, fraction: Double, color: UIColor, title: String?, iconImage: UIImage?, shouldAnimate: Bool) {
        self.color = color
        self.fraction = fraction
        self.thickness = thickness
        self.title = title ?? ""
        self.iconView.image = iconImage ?? nil
        self.shouldAnimate = shouldAnimate
    }
    
    func initialize() {
        let path = createInitialPath(thickness: thickness)
        applySettings(path: path)
    }
    
    func applySettings() {
        let angle = getAngle(fraction: fraction)
        let path = createPath(thickness: thickness, angleRadians: angle, percentComplete: 1.0)
        applySettings(path: path)
    }
    
    internal func applySettings(path: UIBezierPath) {
        shapeLayer.fillColor = color.cgColor
        backgroundLayer.fillColor = color.withAlphaComponent(0.5).cgColor
        backgroundLayer.path = createBackgroundPath().cgPath
        shapeLayer.path = path.cgPath
        label.text = title.uppercased()
        label.textColor = color
    }
    
    func applySettingsAndAnimate(afterDelay: Double, completion: @escaping () -> Void) {
        let dispatchTime: DispatchTime = .now() + DispatchTimeInterval.milliseconds(Int(afterDelay * 1000))
        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
            CATransaction.begin()
            CATransaction.setCompletionBlock(completion)
            self.applySettings()
            self.animateShapeLayout(layer: self.shapeLayer, frames: 3000)
            CATransaction.commit()
        }
    }
    
    internal func animateShapeLayout(layer: CAShapeLayer, frames: Int) {
        let angle = getAngle(fraction: fraction)
        let duration = 1.6
        layer.path = createPath(thickness: thickness, angleRadians: angle, percentComplete: 0.0).cgPath
        let animation = CAKeyframeAnimation(keyPath: "path")
        
        var values = [CGPath]()
        var times = [NSNumber]()
        for i in 0...frames {
            let frame = createPath(thickness: thickness, angleRadians: angle, percentComplete: Double(i)/Double(frames))
            values.append(frame.cgPath)
            times.append(NSNumber(floatLiteral: duration * Double(i)/Double(frames)))
        }
        
        animation.values = values
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        
        layer.add(animation, forKey: nil)
    }
    
    internal func getAngle(fraction: Double) -> Double {
        let degreesInCircle = 2 * M_PI
        return fraction * degreesInCircle
    }
    
    internal func createPath(thickness: Int, angleRadians: Double, percentComplete: Double) -> UIBezierPath {
        let topCenter = CGPoint(x: frame.width / 2, y: 0)
        let cgAngle = CGFloat(angleRadians)
        let path = UIBezierPath()
        let viewCenter = CGPoint(x: frame.width / 2, y: frame.height / 2)
        let zeroAngle = CGFloat(-M_PI/2)
        let finalAngle = (CGFloat(-M_PI / 2) + (cgAngle * CGFloat(percentComplete)))
        path.move(to:topCenter)
        path.addArc(withCenter: viewCenter, radius: frame.height / 2, startAngle: zeroAngle, endAngle: finalAngle, clockwise: true)
        let currentPoint = path.currentPoint
        let x = cos(finalAngle - CGFloat(M_PI)) * (cgThickness / 2)
        let y = sin(finalAngle - CGFloat(M_PI)) * (cgThickness / 2)
        let centerOfSecondArc = CGPoint(x: currentPoint.x + x, y: currentPoint.y + y)
        path.addArc(withCenter: centerOfSecondArc, radius: cgThickness / 2, startAngle: finalAngle, endAngle: finalAngle + CGFloat(M_PI), clockwise: true)
        path.addArc(withCenter: viewCenter, radius: frame.height / 2 - cgThickness, startAngle: finalAngle, endAngle: zeroAngle, clockwise: false)
        let lastCenterPoint = CGPoint(x: frame.width / 2, y: topCenter.y + (cgThickness / 2))
        path.addArc(withCenter: lastCenterPoint, radius: (cgThickness / 2), startAngle: CGFloat(M_PI/2), endAngle: CGFloat(M_PI*(3/2)), clockwise: true)
        path.close()
        //path.fill()
        return path
    }
    
    internal func createBackgroundPath() -> UIBezierPath {
        let topCenter = CGPoint(x: frame.width / 2, y: 0)
        let path = UIBezierPath()
        let viewCenter = CGPoint(x: frame.width / 2, y: frame.height / 2)
        let zeroAngle = CGFloat(0)
        let endAngle = CGFloat(2 * M_PI)
        path.move(to: topCenter)
        path.addArc(withCenter: viewCenter, radius: frame.height / 2, startAngle: zeroAngle, endAngle: endAngle, clockwise: true)
        let topCenterOfInnerCircle = CGPoint(x: topCenter.x, y: topCenter.y + cgThickness)
        path.move(to: topCenterOfInnerCircle)
        path.addArc(withCenter: viewCenter, radius: ((frame.height / 2) - (cgThickness)), startAngle: zeroAngle, endAngle: endAngle, clockwise: true)
        path.close()
        return path
    }
    
    internal func createInitialPath(thickness: Int) -> UIBezierPath {
        return createPath(thickness: thickness, angleRadians: 0.0, percentComplete: 1.0)
    }
    
    internal func setupLabel() {
        label.textColor = color
        label.font = UIFont(name: "Arial Rounded MT Bold", size: cgThickness)
        label.textAlignment = .right
        label.numberOfLines = 1
        //label.adjustsFontSizeToFitWidth = true
        addSubview(label)
    }
    
    internal func setupIcon() {
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = UIColor.black
        addSubview(iconView)
    }
    
    func frameThatFitsInside() -> CGRect {
        let height = frame.height - (2 * CGFloat(thickness + (thickness / 10)))
        let x = frame.minX + CGFloat(thickness + (thickness / 10))
        let y = frame.minY + CGFloat(thickness + (thickness / 10))
        return CGRect(x: x, y: y, width: height, height: height)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var path: UIBezierPath!
        if shouldAnimate {
            path = createInitialPath(thickness: thickness)
        } else {
            let angle = getAngle(fraction: fraction)
            path = createPath(thickness: thickness, angleRadians: angle, percentComplete: 1.0)
        }
        applySettings(path: path)
        label.frame = CGRect(x: -100, y: 0, width: frame.width/2 - 20 + 100, height: cgThickness)
        let center = frame.width/2
        iconView.frame = CGRect(x: center - cgThickness / 4, y: cgThickness / 4, width: cgThickness / 2, height: cgThickness / 2)
    }
    
}
