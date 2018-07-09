//
//  MeterView.swift
//  ProCamera
//
//  Created by Hao Wang on 3/21/15.
//  Copyright (c) 2015 Hao Wang. All rights reserved.
//

import UIKit

class MeterView: UIView {

    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        
        print("MeterView: drawRect \(rect)")
        let context = UIGraphicsGetCurrentContext()
        context?.clear(rect)
        let strokeWidth: CGFloat = 2.0
        let marginWidth: CGFloat = 4.0
        context?.setLineWidth(strokeWidth)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let components: [CGFloat] = [1.0, 1.0, 1.0, 0.9]
        let color = CGColor(colorSpace: colorSpace, components: components)
        context?.setStrokeColor(color!)
        //find max_pixels in histogramRaw
        let meterMarkCount = 20
        let halfHeight = rect.height / 2.0
        // Draw meter from quater height. Leave top and bottom quater height
        // Meter only takes half of total height
        for i in 1 ..< meterMarkCount {
            let y = CGFloat(i) * halfHeight / CGFloat(meterMarkCount) + halfHeight / 2.0
            context?.move(to: CGPoint(x: marginWidth, y: y)) //x = i, y = height
            context?.addLine(to: CGPoint(x: rect.width - marginWidth, y: y))
        }
        context?.strokePath()
    }


}
