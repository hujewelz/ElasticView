//
//  ElasticView.swift
//  ElasticUI
//
//  Created by mac on 15/12/21.
//  Copyright © 2015年 Daniel Tavares. All rights reserved.
//

import UIKit

class ElasticView: UIView {

    private let topControlPointView = UIView()
    private let leftControlPointView = UIView()
    private let bottomControlPointView = UIView()
    private let rightControlPointView = UIView()
    
    private let elasticShape = CAShapeLayer()
    
    @IBInspectable var overshootAmount: CGFloat = 10.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupComponents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupComponents()
    }
    
    private lazy var displayLink: CADisplayLink = {
        let displaylink = CADisplayLink(target: self, selector: Selector("updateLoop"))
        displaylink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        return displaylink
    }()
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        startUpdateLoop()
        animateControlPoints()
    }
    
    override var backgroundColor: UIColor? {
        willSet {
            if let newValue = newValue {
                elasticShape.fillColor = newValue.CGColor
                super.backgroundColor = UIColor.clearColor()
            }
        }
    }
    
    private func setupComponents() {
        elasticShape.fillColor = backgroundColor?.CGColor
        elasticShape.path = UIBezierPath(rect: bounds).CGPath
        //elasticShape.strokeColor = UIColor.blueColor().CGColor
        
        backgroundColor = UIColor.clearColor()
        
        layer.addSublayer(elasticShape)
        
        for controlPoint in [topControlPointView,leftControlPointView,bottomControlPointView,rightControlPointView] {
            self.addSubview(controlPoint)
            controlPoint.frame = CGRect(x: 0.0, y: 0.0, width: 5.0, height: 5.0)
            //controlPoint.backgroundColor = UIColor.redColor()
        }
        
        positonControlPoints()
    }
    
    private func positonControlPoints() {
        topControlPointView.center = CGPoint(x: bounds.midX, y: 0.0)
        leftControlPointView.center = CGPoint(x: 0.0, y: bounds.midY)
        bottomControlPointView.center = CGPoint(x: bounds.midX, y: bounds.maxY)
        rightControlPointView.center = CGPoint(x: bounds.maxX, y: bounds.midY)
    }
    
    private func bezierPathForControlPoints() -> CGPathRef {
        let path = UIBezierPath()
        
        let width = frame.size.width
        let height = frame.size.height
        
        path.moveToPoint(CGPointMake(0, 0))
        
        if let top = topControlPointView.layer.presentationLayer()?.position {
            path.addQuadCurveToPoint(CGPointMake(width, 0), controlPoint: top)
        }
        
        if let right = rightControlPointView.layer.presentationLayer()?.position {
            path.addQuadCurveToPoint(CGPointMake(width, height), controlPoint: right)
        }
        
        if let bottom = bottomControlPointView.layer.presentationLayer()?.position {
            path.addQuadCurveToPoint(CGPointMake(0, height), controlPoint: bottom)
        }
        
        if let left = leftControlPointView.layer.presentationLayer()?.position {
            path.addQuadCurveToPoint(CGPointMake(0, 0), controlPoint: left)
        }
        
        return path.CGPath
    }

    func animateControlPoints() {
        let overshootAmount = self.overshootAmount
        
        UIView.animateWithDuration(0.25, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1.5,
            options:UIViewAnimationOptions.CurveLinear, animations: {
                // 3
                self.topControlPointView.center.y -= overshootAmount
                self.leftControlPointView.center.x -= overshootAmount
                self.bottomControlPointView.center.y += overshootAmount
                self.rightControlPointView.center.x += overshootAmount
            },
            completion: { _ in
                // 4
                UIView.animateWithDuration(0.45, delay: 0.0, usingSpringWithDamping: 0.15, initialSpringVelocity: 5.5,
                    options: .CurveLinear, animations: {
                        // 5
                        self.positonControlPoints()
                    },
                    completion: { _ in
                        // 6
                        self.stopUpdateLoop()
                })
        })
        
    }
    
    func updateLoop() {
        elasticShape.path = bezierPathForControlPoints()
    }
    
    private func startUpdateLoop() {
        displayLink.paused = false
    }
    
    private func stopUpdateLoop() {
        displayLink.paused = true
    }
}
