//
//  SelectedBlockGraphic.swift
//  Minesweeper
//
//  Created by Henri on 07/12/2017.
//  Copyright © 2017 Koulutus. All rights reserved.
//

import UIKit

class SelectedBlockGraphic : GameGraphic {
	
	override func CreateImage(_ _width: Int, height _height: Int?) -> UIImage? {
		let width = CGFloat(_width)
		let height : Int = _height == nil ? _width : _height!
		let size = CGSize(width: _width, height: height)

		UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
		
		// -- Settings
		
		let backgroundColor = UIColor(hue: 202/360.0, saturation: 0.31, brightness: 0.20, alpha: 1)
		let backgroundStrokeColor = UIColor(hue: 212/360.0, saturation: 0.73, brightness: 0.64, alpha: 1)
		
		let foregroundColor = UIColor(hue: 212/360.0, saturation: 0.73, brightness: 0.89, alpha: 1)
		let foregroundStrokeColor = UIColor(hue: 212/360.0, saturation: 0.73, brightness: 1, alpha: 1)
		
		let backgroundSize = width * 0.8
		let foregroundSize = width * 0.2
		
		// -- Pre-calculated values
		
		let midPoint = width * 0.5
		
		// -- Background
		
		backgroundColor.setFill()
		backgroundStrokeColor.setStroke()
		
		let backgroundPath = UIBezierPath(ovalIn: CGRect(x: midPoint - backgroundSize * 0.5, y: midPoint - backgroundSize * 0.5, width: backgroundSize, height: backgroundSize))
		backgroundPath.fill()
		backgroundPath.stroke()
		
		// -- Foreground
		
		foregroundColor.setFill()
		foregroundStrokeColor.setStroke()
		
		let foregroundPath = UIBezierPath(ovalIn: CGRect(x: midPoint - foregroundSize * 0.5, y: midPoint - foregroundSize * 0.5, width: foregroundSize, height: foregroundSize))
		foregroundPath.fill()
		foregroundPath.stroke()
		
		// -- Finished
		
		let image = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		
		return image
	}
	
}
