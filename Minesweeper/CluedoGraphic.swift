//
//  CluedoGraphic.swift
//  Minesweeper
//
//  Created by Koulutus on 31/10/2017.
//  Copyright © 2017 Koulutus. All rights reserved.
//

import UIKit

class CluedoGraphic : GameGraphic {
	
	private var m_threatLevel : Int = 0
	
	static let threatColors : [UIColor] = [ UIColor(hue: 220/360.0, saturation: 0.74, brightness: 1, alpha: 1),
	                                        UIColor(hue: 130/360.0, saturation: 0.84, brightness: 0.67, alpha: 1),
	                                        UIColor(hue: 0/360.0, saturation: 0.77, brightness: 0.93, alpha: 1),
	                                        UIColor(hue: 220/360.0, saturation: 0.85, brightness: 0.49, alpha: 1),
	                                        UIColor(hue: 0/360.0, saturation: 0.92, brightness: 0.63, alpha: 1),
	                                        UIColor(hue: 189/360.0, saturation: 0.87, brightness: 0.62, alpha: 1),
	                                        UIColor(hue: 278/360.0, saturation: 0.86, brightness: 0.83, alpha: 1),
	                                        UIColor(hue: 0/360.0, saturation: 0, brightness: 0.47, alpha: 1) ]
	
	init(_ width: Int, threat: Int) {
		m_threatLevel = threat
		super.init(width)
	}
	
	override func CreateImage(_ _width: Int, height _height: Int? = nil) -> UIImage? {
		let size = CGSize(width: _width, height: _width)

		UIGraphicsBeginImageContextWithOptions(size, false, 0.0)

		// -- Colors
		
		let backgroundColor = UIColor(hue: 212/360.0, saturation: 0.17, brightness: 0.93, alpha: 1)
		let backgroundStrokeColor = UIColor(hue: 212/360.0, saturation: 0.68, brightness: 0.58, alpha: 1)
		
		// -- Params
		
		let backgroundStrokeWidth = size.width * 0.1
		let margin = size.width * 0.1
		
		// -- Pre-calc
		
		let innerSize = size.width - margin * 2
		
		// -- Background
		
		let background = UIBezierPath(ovalIn: CGRect(x: margin + backgroundStrokeWidth, y: margin + backgroundStrokeWidth,
		                                             width: innerSize - backgroundStrokeWidth * 2, height: innerSize - backgroundStrokeWidth * 2))
		background.lineWidth = backgroundStrokeWidth
		backgroundColor.setFill()
		backgroundStrokeColor.setStroke()
		background.fill()
		background.stroke()
		
		// -- Number
		
		if m_threatLevel > 0 {
			let string = String(m_threatLevel)
			let font = UIFont.systemFont(ofSize: size.width * 0.35, weight: UIFontWeightBold)
			let color = CluedoGraphic.threatColors[m_threatLevel - 1]
			let fontHeight = font.lineHeight

			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.alignment = .center

			let attrs = [NSFontAttributeName: font,
			             NSParagraphStyleAttributeName: paragraphStyle,
			             NSForegroundColorAttributeName: color] as [String : Any]
			
			string.draw(with: CGRect(x: 0, y: (size.height - fontHeight) * 0.5, width: size.width, height: fontHeight), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
		}
		
		// -- Output
		
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return image
	}
	
	/// Predator-esque threat dots
	
	private func DrawPredatorDots(width _width: CGFloat, halfWidth hWidth: CGFloat) {
		let threatLevelDelta = CGFloat(m_threatLevel) / 8
		
		let threatColor = UIColor(hue: 0, saturation: 0.69, brightness: 0.35 + 0.4 * pow(threatLevelDelta, 0.8), alpha: 1)
		let threatShadowColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.75)
		
		let threatSize = _width * 0.125
		let threatCornerRadius = threatSize * 0.5
		let threatMargin = _width * 0.04
		let threatShadowBlurRadius: CGFloat = _width * 0.2
		
		// -- Calculated
		
		let hThreatSize = threatSize * 0.5
		let context = UIGraphicsGetCurrentContext()!
		
		context.setShadow(offset: CGSize.zero, blur: threatShadowBlurRadius, color: threatShadowColor.cgColor)
		context.beginTransparencyLayer(auxiliaryInfo: nil)
		
		threatColor.setFill()
		
		switch (m_threatLevel) {
		case 1...3:
			let startX : CGFloat = hWidth - CGFloat(m_threatLevel - 1) * threatMargin - CGFloat(m_threatLevel) * threatSize * 0.5
			
			for i in 0..<m_threatLevel {
				let threatDot = UIBezierPath(roundedRect: CGRect(x: startX + (threatMargin * 2 + threatSize) * CGFloat(i) , y: hWidth - hThreatSize, width: threatSize, height: threatSize), cornerRadius: threatCornerRadius)
				threatDot.fill()
			}
		case 4, 5, 8:
			let matrix : [Bool]
			
			if m_threatLevel == 4 {
				matrix = [ false, true, false,
				           true, false, true,
				           false, true, false ]
			} else if m_threatLevel == 5 {
				matrix = [ false, true, false,
				           true, true, true,
				           false, true, false ]
			} else {
				matrix = [ true, true, true,
				           true, false, true,
				           true, true, true ]
			}
			
			let start : CGFloat = hWidth - 2 * threatMargin - 3 * threatSize * 0.5
			
			for x in 0...2 {
				for y in 0...2 {
					if matrix[x + y * 3] {
						let threatDot = UIBezierPath(roundedRect: CGRect(x: start + (threatMargin * 2 + threatSize) * CGFloat(x),
						                                                 y: start + (threatMargin * 2 + threatSize) * CGFloat(y),
						                                                 width: threatSize, height: threatSize), cornerRadius: threatCornerRadius)
						threatDot.fill()
					}
				}
			}
		case 6:
			let startX : CGFloat = hWidth - 2 * threatMargin - 3 * threatSize * 0.5
			let startY : CGFloat = hWidth - 1 * threatMargin - 2 * threatSize * 0.5
			
			for x in 0...2 {
				for y in 0...1 {
					let threatDot = UIBezierPath(roundedRect: CGRect(x: startX + (threatMargin * 2 + threatSize) * CGFloat(x),
					                                                 y: startY + (threatMargin * 2 + threatSize) * CGFloat(y),
					                                                 width: threatSize, height: threatSize), cornerRadius: threatCornerRadius)
					threatDot.fill()
				}
			}
		case 7:
			var startX : CGFloat = hWidth - 2 * threatMargin - 3 * threatSize * 0.5
			var startY : CGFloat = hWidth - 1 * threatMargin - 2 * threatSize * 0.5
			
			for x in 0...2 {
				for y in 0...1 {
					if x != 1 {
						let threatDot = UIBezierPath(roundedRect: CGRect(x: startX + (threatMargin * 2 + threatSize) * CGFloat(x),
						                                                 y: startY + (threatMargin * 2 + threatSize) * CGFloat(y),
						                                                 width: threatSize, height: threatSize), cornerRadius: threatCornerRadius)
						threatDot.fill()
					}
				}
			}
			
			startX = hWidth - threatSize * 0.5
			startY = hWidth - 2 * threatMargin - 3 * threatSize * 0.5
			
			for y in 0...2 {
				let threatDot = UIBezierPath(roundedRect: CGRect(x: startX,
				                                                 y: startY + (threatMargin * 2 + threatSize) * CGFloat(y),
				                                                 width: threatSize, height: threatSize), cornerRadius: threatCornerRadius)
				threatDot.fill()
			}
		default:
			break
		}
		
		context.endTransparencyLayer()
		context.setShadow(offset: CGSize.zero, blur: 0)
	}
	
}
