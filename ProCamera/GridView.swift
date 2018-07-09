//
//  GridView.swift
//  ProCamera
//
//  Created by Hao Wang on 3/22/15.
//  Copyright (c) 2015 Hao Wang. All rights reserved.
//

import UIKit

class GridView: UIView {

    let strokeWidth: CGFloat = 1.0
    let mainColorVal: [CGFloat] = [1.0, 1.0, 1.0, 0.7]
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        let context = UIGraphicsGetCurrentContext()
        context?.clear(rect)
        context?.setLineWidth(strokeWidth)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let color = CGColor(colorSpace: colorSpace, components: mainColorVal)
        context?.setStrokeColor(color!)
        //Draw horizontal 2 lines
        context?.move(to: CGPoint(x: 0.0, y: rect.height / 3.0))
        context?.addLine(to: CGPoint(x: rect.width, y: rect.height / 3.0))
        context?.move(to: CGPoint(x: 0.0, y: rect.height * 2.0 / 3.0))
        context?.addLine(to: CGPoint(x: rect.width, y: rect.height * 2.0 / 3.0))
        
        //Draw vertical 2 lines
        context?.move(to: CGPoint(x: rect.width / 3.0, y: 0.0))
        context?.addLine(to: CGPoint(x: rect.width / 3.0, y: rect.height))
        context?.move(to: CGPoint(x: rect.width * 2.0 / 3.0, y: 0.0))
        context?.addLine(to: CGPoint(x: rect.width * 2.0 / 3.0, y: rect.height))
        
        context?.strokePath()
    }


}
