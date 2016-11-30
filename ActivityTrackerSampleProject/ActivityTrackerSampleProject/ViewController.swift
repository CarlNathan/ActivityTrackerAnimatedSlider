//
//  ViewController.swift
//  ActivityTrackerSampleProject
//
//  Created by Carl Udren on 11/21/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let outerCicle = CircleSliderView()
    let middleCircle = CircleSliderView()
    let innerCircle = CircleSliderView()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //background color
        view.backgroundColor = UIColor.black
        
        //add circle views to view
        view.addSubview(outerCicle)
        view.addSubview(middleCircle)
        view.addSubview(innerCircle)

        //setup cirles
        let thickness = 30
        let fraction1 = 0.9
        let fraction2 = 0.7
        let fraction3 = 0.8
        let color1 = UIColor.init(colorLiteralRed: 255/255, green: 37/255, blue: 33/255, alpha: 1)
        let color2 = UIColor.init(colorLiteralRed: 160/255, green: 249/255, blue: 7/255, alpha: 1)
        let color3 = UIColor.init(colorLiteralRed: 18/255, green: 212/255, blue: 222/255, alpha: 1)
        let upImage = UIImage(named: "Up Arrow")?.withRenderingMode(.alwaysTemplate)
        let rightImage = UIImage(named: "Right Arrow")?.withRenderingMode(.alwaysTemplate)
        let doubleRightImage = UIImage(named: "Double Right Arrow")?.withRenderingMode(.alwaysTemplate)
        outerCicle.configure(thickness: thickness, fraction: fraction1, color: color1, title: "Move", iconImage: rightImage, shouldAnimate: true)
        middleCircle.configure(thickness: thickness, fraction: fraction2, color: color2, title: "Exercise", iconImage: doubleRightImage, shouldAnimate: true)
        innerCircle.configure(thickness: thickness, fraction: fraction3, color: color3, title: "Stand", iconImage: upImage, shouldAnimate: true)
        
        outerCicle.initialize()
        middleCircle.initialize()
        innerCircle.initialize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        outerCicle.applySettingsAndAnimate(afterDelay: 0.0, completion: {})
        middleCircle.applySettingsAndAnimate(afterDelay: 0.5, completion: {})
        innerCircle.applySettingsAndAnimate(afterDelay: 1.0, completion: {})
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //I'm setting frames for the circle sliders manually.  Make sure the insets match the thicknesses of the cirlces for a seamless fit.
        
        outerCicle.frame = CGRect(x: 20, y: 100, width: view.frame.width - 40, height: view.frame.width - 40)
        middleCircle.frame = outerCicle.frameThatFitsInside()
        innerCircle.frame = middleCircle.frameThatFitsInside()
    }


}

