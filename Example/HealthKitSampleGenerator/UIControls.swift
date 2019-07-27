//
//  UIControls.swift
//  HealthKitSampleGenerator
//
//  Created by Michael Seemann on 06.10.15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

public class BaselineTextField : UITextField {
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        borderStyle = UITextBorderStyle.none
        
    }
 
    override public func draw(_ rect: CGRect) {
        if let ctx = UIGraphicsGetCurrentContext(){
        ctx.setLineWidth(1.0)
        ctx.setStrokeColor(UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0).cgColor)
        ctx.move(to: CGPoint(x: 0, y: rect.size.height))
        ctx.addLine(to: .init(x: rect.size.width, y: rect.size.height))
        ctx.strokePath()
        }
    }
}
