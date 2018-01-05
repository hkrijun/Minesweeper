//
//  BombGraphic.swift
//  Minesweeper
//
//  Created by Koulutus on 17/10/2017.
//  Copyright © 2017 Koulutus. All rights reserved.
//

import UIKit

class BombGraphic : GameGraphic {
	
	private var m_drawGlow : Bool = true

 	init(_ width: Int, drawGlow: Bool = true) {
		m_drawGlow = drawGlow
		super.init(width)
	}
	
	override func CreateImage(_ width: Int, height: Int? = nil) -> UIImage? {
		let size = CGSize(width: width, height: width)
		let hWidth = size.width * 0.5
		
		UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
		let context = UIGraphicsGetCurrentContext()!

		// -- Colors
		
		//let backgroundColor = UIColor(hue: 350/360.0, saturation: 0.93, brightness: 0.91, alpha: 1) // UIColor(red: 0.65, green: 0, blue: 0, alpha: 1)
		//let backgroundStrokeColor = UIColor(hue: 350/360.0, saturation: 0.93, brightness: 0.72, alpha: 1)
		let shadowColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
		
		let bombFillColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
		let bombShadingColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1)
		let bombOutlineColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1)
		let cartoonEdgeColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
		
		let spikeHeadColor = UIColor(red: 0.125, green: 0.125, blue: 0.125, alpha: 1)
		let spikeColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)
		let innerSpikeColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)
		let innerSpikeColorHighlight = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
		let innerSpikePointColor = UIColor(red: 0.125, green: 0.125, blue: 0.125, alpha: 1)
		
		// -- Sizes
		
		let margins : CGFloat = size.width * 0.2
		
		let hWidthInner = hWidth - margins
		let widthInner = size.width - margins * 2
		
		let bombShadingDistance : CGFloat = widthInner * 0.1
		let bombOutlineWidth : CGFloat = widthInner * 0.075
		let bombCartoonEdge : CGFloat = widthInner * 0.075
		
		let spikeLength : CGFloat = widthInner * 0.15
		let spikeWidth : CGFloat = widthInner * 0.2
		let spikeSpacing : CGFloat = 0.33
		let spikeHeadExtension : CGFloat = 1.15
		
		let innerSpikeSize : CGFloat = widthInner * 0.33
		let innerSpikeSpacing : CGFloat = widthInner * 0.133
		let innerSpikePointSize = innerSpikeSize * 0.4
		
		let shadowBlurRadius: CGFloat = margins + spikeLength * 0.9
		
		// -- Background
		/*
		let background = UIBezierPath(roundedRect: CGRect(x: 2, y: 2, width: size.width - 4, height: size.height - 4), cornerRadius: size.width * 0.25)
		backgroundColor.setFill()
		background.fill()
		backgroundStrokeColor.setStroke()
		background.stroke()
		*/
		// Add Shadow
		
		if m_drawGlow {
			context.setShadow(offset: CGSize.zero, blur: shadowBlurRadius, color: shadowColor.cgColor)
			context.beginTransparencyLayer(auxiliaryInfo: nil)
		}
		
		// -- Cartoony edge
		
		cartoonEdgeColor.setFill()
		UIBezierPath(roundedRect: CGRect(x: bombCartoonEdge + margins,
		                                 y: bombCartoonEdge + margins,
		                                 width: widthInner - bombCartoonEdge * 2,
		                                 height: widthInner - bombCartoonEdge * 2),
		             cornerRadius: widthInner * 0.5 ).fill()
		
		// For shadow
		
		if m_drawGlow {
			context.endTransparencyLayer()
			context.setShadow(offset: CGSize.zero, blur: 0)
		}
		
		// -- Spikes
		
		let spikePath = UIBezierPath()
		let spikeHeadPath = UIBezierPath()
		
		let spikeHeadExtensionReverse = 1 / spikeHeadExtension
		
		for startAngle in stride(from: 0, through: CGFloat.pi, by: CGFloat.pi * spikeSpacing) {
			
			// -- Head
			
			var x : CGFloat = hWidth + (hWidthInner * spikeHeadExtension) * cos(startAngle)
			var y : CGFloat = hWidth + (hWidthInner * spikeHeadExtension) * sin(startAngle)
			spikeHeadPath.move(to: CGPoint(x: x, y: y))
			
			var endAngle = startAngle + CGFloat.pi
			x = hWidth + (hWidthInner * spikeHeadExtension) * cos(endAngle)
			y = hWidth + (hWidthInner * spikeHeadExtension) * sin(endAngle)
			spikeHeadPath.addLine(to: CGPoint(x: x, y: y))
			
			// Body
			
			x = hWidth + hWidthInner * cos(startAngle) * spikeHeadExtensionReverse
			y = hWidth + hWidthInner * sin(startAngle) * spikeHeadExtensionReverse
			spikePath.move(to: CGPoint(x: x, y: y))
			
			endAngle = startAngle + CGFloat.pi
			x = hWidth + hWidthInner * cos(endAngle) * spikeHeadExtensionReverse
			y = hWidth + hWidthInner * sin(endAngle) * spikeHeadExtensionReverse
			spikePath.addLine(to: CGPoint(x: x, y: y))
		}
		
		spikeHeadPath.lineWidth = spikeWidth * 0.5
		spikeHeadColor.setStroke()
		spikeHeadPath.stroke()
		
		spikePath.lineCapStyle = .round
		spikePath.lineWidth = spikeWidth
		spikeColor.setStroke()
		spikePath.stroke()
		
		// -- Bomb
		
		let bombPath = UIBezierPath(roundedRect: CGRect(x: spikeLength + margins, y: spikeLength + margins,
		                                                width: widthInner - spikeLength * 2,
		                                                height: widthInner - spikeLength * 2),
		                            cornerRadius: widthInner * 0.5 )
		
		bombPath.lineWidth = bombOutlineWidth
		bombFillColor.setFill()
		bombOutlineColor.setStroke()
		bombPath.stroke()
		bombPath.fill()
		
		// -- Bomb shading

		bombShadingColor.setFill()
		UIBezierPath(roundedRect: CGRect(x: spikeLength + margins,
		                                 y: spikeLength + margins,
		                                 width: widthInner - spikeLength * 2 - bombShadingDistance,
		                                 height: widthInner - spikeLength * 2 - bombShadingDistance),
		             cornerRadius: widthInner * 0.5 ).fill()
		
		// -- Inner spikes
		
		let innerSpikeHighlightOffset : CGFloat = 0.5
		
		for ix in -1...1 {
			for iy in -1...1 {
				if ix == 0 && iy == 0 { //(ix != 0 && iy != 0) { // || (ix == 0 && iy == 0)
					innerSpikeColor.setFill()
					
					UIBezierPath(roundedRect: CGRect(
						x: hWidth - innerSpikeSize * 0.5 + CGFloat(ix) * innerSpikeSpacing,
						y: hWidth - innerSpikeSize * 0.5 + CGFloat(iy) * innerSpikeSpacing,
						width: innerSpikeSize, height: innerSpikeSize),
					                                  cornerRadius: innerSpikeSize * 0.33).fill()
					
					// Highlight
					
					innerSpikeColorHighlight.setFill()
					
				 UIBezierPath(roundedRect: CGRect(
						x: hWidth - innerSpikeSize * 0.5 + CGFloat(ix) * innerSpikeSpacing + innerSpikeHighlightOffset,
						y: hWidth - innerSpikeSize * 0.5 + CGFloat(iy) * innerSpikeSpacing + innerSpikeHighlightOffset,
						width: innerSpikeSize * 0.66, height: innerSpikeSize * 0.66),
					                              cornerRadius: innerSpikeSize * 0.25).fill()
					
					// Point
					
					innerSpikePointColor.setFill()
					
					UIBezierPath(ovalIn: CGRect(
						x: hWidth + CGFloat(ix) * innerSpikeSpacing - innerSpikePointSize * 0.5,
						y: hWidth + CGFloat(iy) * innerSpikeSpacing - innerSpikePointSize * 0.5,
						width: innerSpikePointSize,
						height: innerSpikePointSize)).fill()
				}
			}
		}
		
		//This code must always be at the end of the playground
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

		return image
	}

}
