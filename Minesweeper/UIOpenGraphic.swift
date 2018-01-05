//
//  UIOpenGraphic.swift
//  Minesweeper
//
//  Created by Koulutus on 08/11/2017.
//  Copyright © 2017 Koulutus. All rights reserved.
//

import UIKit

class UIOpenGraphic : GameGraphic {
	
	enum PointerPosition : Int {
		case top = 0, bottom = 1
	}
	
	enum Icon : Int {
		case shovel = 0, flag = 1
	}
	
	enum SubType : Int {
		case none = 0, remove = 1
	}
	
	private var m_pointerPosition : PointerPosition = .top
	private var m_icon : Icon = .shovel
	private var m_subType : SubType = .none
	private var m_onlyIcon : Bool = false
	
	/// In-game menu icon constructor
	init(_ width: Int, pointerPosition: PointerPosition, icon: Icon, subType: SubType = .none) {
		m_pointerPosition = pointerPosition
		m_icon = icon
		m_subType = subType
		
		super.init(width)
	}
	
	/// Icon constructor
	init(_ width: Int, icon: Icon) {
		m_icon = icon
		m_onlyIcon = true
		
		super.init(width)
	}

	override func CreateImage(_ width: Int, height _height: Int? = nil) -> UIImage? {
		let height : Int = _height == nil ? width : _height!
		let size : CGFloat = CGFloat(width)
		let hSize : CGFloat = size * 0.5
	
		return m_onlyIcon ? CreateIcon(width: width, height: height, size: size, hSize: hSize) : CreateInGameMenuIcon(width: width, height: height, size: size, hSize: hSize)
	}
	
	private func CreateIcon(width: Int, height: Int, size: CGFloat, hSize: CGFloat) -> UIImage? {
		let canvasSize = CGSize(width: width, height: height)
		
		UIGraphicsBeginImageContextWithOptions(canvasSize, false, 0.0)
		
		switch (m_icon) {
		case .flag:
			DrawFlag(size: size, hSize: hSize)
		case .shovel:
			DrawShovel(size: size, hSize: hSize)
		}
		
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return image
	}
	
	private func CreateInGameMenuIcon(width: Int, height: Int, size: CGFloat, hSize: CGFloat) -> UIImage? {
		// -- Colours
		
		let backgroundColor = UIColor(hue: 116/360.0, saturation: 0.9, brightness: 0.95, alpha: 1)
		let backgroundShadeColor = UIColor(hue: 116/360.0, saturation: 0.9, brightness: 0.79, alpha: 1)
		let backgroundStrokeColor = UIColor(hue: 115/360.0, saturation: 0.9, brightness: 0.62, alpha: 1)
		let removeColor = UIColor(hue: 0.95, saturation: 1, brightness: 0.8, alpha: 1)
		let pointerColor = m_subType == .remove ? removeColor : UIColor.white
		
		// -- Params
		
		let pointerSize : CGFloat = size * 0.2
		let rimSize : CGFloat = size * 0.075
		let backgroundStrokeSize : CGFloat = size * 0.05
		let shadeOffset : CGFloat = size * 0.125
		
		// -- Pre-calc values
		
		let hPointerSize : CGFloat = pointerSize * 0.5
		let iconBackgroundSize : CGFloat = size - rimSize * 2
		let canvasSize = CGSize(width: width, height: height + Int(hPointerSize))
		
		UIGraphicsBeginImageContextWithOptions(canvasSize, false, 0.0)
		
		// -- Pointer
		
		let pointerY : [CGFloat] = [ 0, size - hPointerSize ]
		
		pointerColor.setFill()
		UIBezierPath(ovalIn: CGRect(x: hSize - hPointerSize, y: pointerY[m_pointerPosition.rawValue], width: pointerSize, height: pointerSize)).fill()
		
		// -- Icon background
		
		let iconY : [CGFloat] = [ hPointerSize, 0 ]
		let iconBackground = UIBezierPath(ovalIn: CGRect(x: rimSize + backgroundStrokeSize * 0.5,
		                                                 y: iconY[m_pointerPosition.rawValue] + rimSize + backgroundStrokeSize * 0.5,
		                                                 width: iconBackgroundSize - backgroundStrokeSize,
		                                                 height: iconBackgroundSize - backgroundStrokeSize))
		backgroundShadeColor.setFill()
		iconBackground.fill()
		
		backgroundColor.setFill()
		UIBezierPath(ovalIn: CGRect(x: rimSize + backgroundStrokeSize * 0.5 + shadeOffset,
		                            y: iconY[m_pointerPosition.rawValue] + rimSize + backgroundStrokeSize * 0.5,
		                            width: iconBackgroundSize - backgroundStrokeSize - shadeOffset,
		                            height: iconBackgroundSize - backgroundStrokeSize - shadeOffset)).fill()
		
		iconBackground.lineWidth = backgroundStrokeSize
		backgroundStrokeColor.setStroke()
		iconBackground.stroke()
		
		// -- Icon rim
		
		let iconBackgroundRim = UIBezierPath(ovalIn: CGRect(x: rimSize * 0.5, y: iconY[m_pointerPosition.rawValue] + rimSize * 0.5,
		                                                    width: size - rimSize, height: size - rimSize))
		iconBackgroundRim.lineWidth = rimSize
		pointerColor.setStroke()
		iconBackgroundRim.stroke()
		
		// -- Icon
		
		switch (m_icon) {
		case .flag:
			DrawFlag(size: size, hSize: hSize, hPointerSize: hPointerSize)
		case .shovel:
			DrawShovel(size: size, hSize: hSize, hPointerSize: hPointerSize)
		}
		
		// -- SubType
		
		switch (m_subType) {
		case .none:
			break
		case .remove:
			DrawRedCross(size: size, hSize: hSize, hPointerSize: hPointerSize, color: removeColor)
		}

		// -- Output
		
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return image
	}
	
	private func DrawFlag(size: CGFloat, hSize: CGFloat, hPointerSize: CGFloat = 0) {
		let stickColor = UIColor(hue: 40/360.0, saturation: 0.57, brightness: 0.55, alpha: 1)
		let stickShadeColor = UIColor(hue: 48/360.0, saturation: 0.57, brightness: 0.58, alpha: 1)
		let flagColor = UIColor.white
		
		let stickWidth = size * 0.085
		let stickHeight = size * 0.65
		let stickShadeWidth = stickWidth * 0.3
		
		let flagWidth = size * 0.3
		let flagHeight = size * 0.2
		
		let iconYCenter : [CGFloat] = [ hSize + hPointerSize, hSize ]
		
		let context = UIGraphicsGetCurrentContext()!
		
		// -- Stick
		
		context.translateBy(x: hSize, y: iconYCenter[m_pointerPosition.rawValue])
		context.rotate(by: CGFloat.pi * 0.1)
		context.translateBy(x: -hSize, y: -iconYCenter[m_pointerPosition.rawValue])
		
		stickColor.setFill()
		UIBezierPath(roundedRect: CGRect(x: hSize - stickWidth * 0.5, y: iconYCenter[m_pointerPosition.rawValue] - stickHeight * 0.5,
		                                 width: stickWidth, height: stickHeight), cornerRadius: 2).fill()
		
		stickShadeColor.setFill()
		UIBezierPath(rect: CGRect(x: hSize - stickWidth * 0.25, y: iconYCenter[m_pointerPosition.rawValue] - stickHeight * 0.5,
		                          width: stickShadeWidth, height: stickHeight )).fill()
		
		// -- Flag
		
		flagColor.setFill()
		
		UIBezierPath(rect: CGRect(x: hSize - stickWidth * 0.5,
		                          y: iconYCenter[m_pointerPosition.rawValue] - stickHeight * 0.5 + flagHeight * 0.2,
		                          width: stickWidth, height: flagHeight * 0.5 )).fill()
		
		UIBezierPath(rect: CGRect(x: hSize + stickWidth * 0.5,
		                          y: iconYCenter[m_pointerPosition.rawValue] - stickHeight * 0.5 + flagHeight * 0.1,
		                          width: flagWidth * 0.6, height: flagHeight )).fill()
		
		UIBezierPath(rect: CGRect(x: hSize + stickWidth * 0.5 + flagWidth * 0.6,
		                          y: iconYCenter[m_pointerPosition.rawValue] - stickHeight * 0.5 + flagHeight * 0.2,
		                          width: flagWidth * 0.2, height: flagHeight )).fill()
		
		UIBezierPath(rect: CGRect(x: hSize + stickWidth * 0.5 + flagWidth * 0.8,
		                          y: iconYCenter[m_pointerPosition.rawValue] - stickHeight * 0.5 + flagHeight * 0.3,
		                          width: flagWidth * 0.2, height: flagHeight )).fill()
		
		context.translateBy(x: hSize, y: iconYCenter[m_pointerPosition.rawValue])
		context.rotate(by: CGFloat.pi * -0.1)
		context.translateBy(x: -hSize, y: -iconYCenter[m_pointerPosition.rawValue])
	}
	
	private func DrawShovel(size: CGFloat, hSize: CGFloat, hPointerSize: CGFloat = 0) {
		let stickColor = UIColor(hue: 40/360.0, saturation: 0.57, brightness: 0.55, alpha: 1)
		let stickShadeColor = UIColor(hue: 48/360.0, saturation: 0.57, brightness: 0.58, alpha: 1)
		
		let bladeColor = UIColor(hue: 40/360.0, saturation: 0.1, brightness: 0.34, alpha: 1)
		let bladeShadeColor = UIColor(hue: 30/360, saturation: 0.1, brightness: 0.33, alpha: 1)
		let bladeShade2Color = UIColor(hue: 30/360, saturation: 0.1, brightness: 0.31, alpha: 1)
		let bladeShade3Color = UIColor(hue: 26/360, saturation: 0.09, brightness: 0.28, alpha: 1)
		
		let stickWidth : CGFloat = size * 0.075
		let stickHeight : CGFloat = size * 0.45
		let stickShadeWidth = stickWidth * 0.3
		
		let bladeWidth : CGFloat = size * 0.2
		let bladeHeight : CGFloat = size * 0.25
		
		let iconYCenter : [CGFloat] = [ hSize + hPointerSize, hSize ]
		
		// -- Stick
		
		let context = UIGraphicsGetCurrentContext()!
		
		context.translateBy(x: hSize, y: iconYCenter[m_pointerPosition.rawValue])
		context.rotate(by: CGFloat.pi * 0.1)
		context.translateBy(x: -hSize, y: -iconYCenter[m_pointerPosition.rawValue])
		
		stickColor.setFill()
		UIBezierPath(roundedRect: CGRect(x: hSize - stickWidth * 0.5,
		                                 y: iconYCenter[m_pointerPosition.rawValue] - (stickHeight + bladeHeight) * 0.5,
		                                 width: stickWidth, height: stickHeight + 1), cornerRadius: 1).fill()
		
		stickShadeColor.setFill()
		UIBezierPath(rect: CGRect(x: hSize - stickWidth * 0.25,
		                          y: iconYCenter[m_pointerPosition.rawValue] - (stickHeight + bladeHeight) * 0.5,
		                          width: stickShadeWidth, height: stickHeight)).fill()
		
		// -- Blade
		
		let bladeY : CGFloat = iconYCenter[m_pointerPosition.rawValue] + stickHeight * 0.5 - bladeHeight * 0.5
		
		bladeColor.setFill()
		UIBezierPath(roundedRect: CGRect(x: hSize - bladeWidth * 0.5, y: bladeY,
		                                 width: bladeWidth, height: bladeHeight),
		             byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: bladeWidth * 0.33, height: bladeHeight * 0.5)).fill()
		
		bladeShadeColor.setFill()
		UIBezierPath(rect: CGRect(x: hSize - stickWidth * 0.5, y: bladeY, width: stickWidth * 0.4, height: bladeHeight * 0.4)).fill()
		
		bladeShade2Color.setFill()
		UIBezierPath(rect: CGRect(x: hSize - bladeWidth * 0.5, y: bladeY, width: bladeWidth, height: bladeHeight * 0.15)).fill()
		UIBezierPath(rect: CGRect(x: hSize - stickWidth * 0.5, y: bladeY, width: stickWidth * 0.2, height: bladeHeight * 0.4)).fill()
		UIBezierPath(rect: CGRect(x: hSize + stickWidth * 0.2, y: bladeY, width: stickWidth * 0.2, height: bladeHeight * 0.3)).fill()
		
		bladeShade3Color.setFill()
		UIBezierPath(rect: CGRect(x: hSize - bladeWidth * 0.5, y: bladeY, width: bladeWidth, height: bladeHeight * 0.05)).fill()
		
		context.translateBy(x: hSize, y: iconYCenter[m_pointerPosition.rawValue])
		context.rotate(by: CGFloat.pi * -0.1)
		context.translateBy(x: -hSize, y: -iconYCenter[m_pointerPosition.rawValue])
	}
	
	private func DrawRedCross(size: CGFloat, hSize: CGFloat, hPointerSize: CGFloat, color redCrossColor: UIColor) {
		let redCrossSize = size * 0.5 * 0.6
		let redCrossWidth = size * 0.05
		
		let context = UIGraphicsGetCurrentContext()!
		let iconYCenter : [CGFloat] = [ hSize + hPointerSize, hSize ]
		
		context.addLines(between: [ CGPoint(x: hSize + redCrossSize, y: iconYCenter[m_pointerPosition.rawValue] - redCrossSize),
		                            CGPoint(x: hSize - redCrossSize, y: iconYCenter[m_pointerPosition.rawValue] + redCrossSize) ])
		context.addLines(between: [ CGPoint(x: hSize - redCrossSize, y: iconYCenter[m_pointerPosition.rawValue] - redCrossSize),
		                            CGPoint(x: hSize + redCrossSize, y: iconYCenter[m_pointerPosition.rawValue] + redCrossSize) ])
		context.setLineWidth(redCrossWidth)
		context.setStrokeColor(redCrossColor.cgColor)
		context.setLineCap(.round)
		context.strokePath()
	}
	
}
