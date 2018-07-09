//
//  HistogramView.swift
//  ProCamera
//
//  Created by Hao Wang on 3/19/15.
//  Copyright (c) 2015 Hao Wang. All rights reserved.
//

import UIKit

class HistogramView: UIView {
    
    var histogramRaw: [Int]!
    var strokeWidth: CGFloat = 8.0

    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        if histogramRaw != nil {
            let context = UIGraphicsGetCurrentContext()
            context?.clear(rect)
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let mainColorVal: [CGFloat] = [1.0, 1.0, 1.0, 0.8]
            let bgColorVal: [CGFloat] = [0.0, 0.0, 0.0, 0.2]
            let bgColor = CGColor(colorSpace: colorSpace, components: bgColorVal)
            let color = CGColor(colorSpace: colorSpace, components: mainColorVal)
            context?.setStrokeColor(color!)
            //find max_pixels in histogramRaw
            var max_pixels = histogramRaw[0]
            for i in 1 ..< histogramRaw.count {
                if histogramRaw[i] > max_pixels {
                    max_pixels = histogramRaw[i]
                }
            }
            
            //draw BG
            context?.setLineWidth(strokeWidth + 2.0)
            context?.setStrokeColor(bgColor!)
            //map max_pixels to rect.height
            // height = x / max_pixels * rect.height
            for i in 0 ..< histogramRaw.count {
                var value_height = CGFloat(histogramRaw[i]) / CGFloat(max_pixels) * CGFloat(rect.height)
                if value_height < 1.0 {
                    value_height = 1.0 //min height = 1.0
                }
                context?.move(to: CGPoint(x: CGFloat(i) * strokeWidth + strokeWidth / 2.0, y: rect.height)) //x = i, y = height
                context?.addLine(to: CGPoint(x: CGFloat(i) * strokeWidth + strokeWidth / 2.0, y: rect.height - value_height - 2.0)) //x = i, y = height - value_height
            }
            context?.strokePath()
            //Draw bar
            context?.setLineWidth(strokeWidth - 2.0)
            context?.setStrokeColor(color!)

            for i in 0 ..< histogramRaw.count {
                var value_height = CGFloat(histogramRaw[i]) / CGFloat(max_pixels) * CGFloat(rect.height)
                if value_height < 1.0 {
                    value_height = 1.0 //min height = 1.0
                }
                context?.move(to: CGPoint(x: CGFloat(i) * strokeWidth + strokeWidth / 2.0, y: rect.height - 2.0)) //x = i, y = height
                var heightTo = rect.height - value_height
                if heightTo <= 2.0 {
                    heightTo = 2.0
                }
                context?.addLine(to: CGPoint(x: CGFloat(i) * strokeWidth + strokeWidth / 2.0, y: heightTo)) //x = i, y = height - value_height
            }
            context?.strokePath()
        }
    }
    
    func didUpdateHistogramRaw(_ data: [Int]) {
        histogramRaw = data
        
        self.setNeedsDisplay()
    }
}
