//
//  RiddlerGraphic.swift
//  Minesweeper
//
//  Created by Koulutus on 30/10/2017.
//  Copyright © 2017 Koulutus. All rights reserved.
//

import UIKit

class RiddlerGraphic : GameGraphic {
	
	enum BlockType : Int {
		case topLeftCorner = 0, topRightCorner = 1, bottomRightCorner = 2, bottomLeftCorner = 3,
			  topEnd = 4, rightEnd = 5, bottomEnd = 6, leftEnd = 7,
			  lone = 8, surrounded = 9
		
		case count = 10
	}
	
	private enum DrawLineTo {
		case right, bottom, both, none
	}
	
	private var m_blockType : Int = 0
	private var m_backgroundColor : UIColor
	private var m_strokeColor : UIColor
	private var m_margins : CGFloat
	
	init(_ width: Int, blockType: Int, backgroundColor: UIColor, strokeColor: UIColor, margins: CGFloat = 0) {
		m_blockType = blockType
		m_backgroundColor = backgroundColor
		m_strokeColor = strokeColor
		m_margins = margins
		
		super.init(width)
	}
	
	override func CreateImage(_ width: Int, height: Int? = nil) -> UIImage? {
		let size = CGSize(width: width, height: width)
		
		UIGraphicsBeginImageContextWithOptions(size, false, 0.0)

		// -- Colors
		
		let backgroundColor = m_backgroundColor
		let strokeColor = m_strokeColor
		
		// -- Sizes

		let cornerRadius : CGFloat = size.width * GameGraphic.m_tileCornerRadius
		let margins : CGFloat = size.width * (GameGraphic.m_tileMargins == 0 ? 1 : GameGraphic.m_tileMargins) * m_margins // Ensures constructor set margins is used in case global margins is set to zero

		// -- Background
		
		// Array order from BlockType enum
		let corners : [UIRectCorner] = [ UIRectCorner.topLeft,
		                                 UIRectCorner.topRight,
		                                 UIRectCorner.bottomRight,
		                                 UIRectCorner.bottomLeft,
		                                 [UIRectCorner.topLeft, UIRectCorner.topRight],
		                                 [UIRectCorner.topRight, UIRectCorner.bottomRight],
		                                 [UIRectCorner.bottomRight, UIRectCorner.bottomLeft],
		                                 [UIRectCorner.bottomLeft, UIRectCorner.topLeft],
		                                 UIRectCorner.allCorners
		]
		
		let lines : [DrawLineTo] = [ .both, .bottom, .none, .right,
											  .bottom, .none, .none, .right,
											  .none, .both
		]
		
		var background : UIBezierPath
		let rect = CGRect(x: margins, y: margins, width: size.width - margins * 2, height: size.height - margins * 2)
			
		if m_blockType < 9 {
			background = UIBezierPath(roundedRect: rect,
											  byRoundingCorners: corners[m_blockType],
											  cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
		} else {
			background = UIBezierPath(rect: rect)
		}
		
		backgroundColor.setFill()
		background.fill()
		
		strokeColor.setStroke()
		let blockLines = UIBezierPath()
		DrawLine(blockLines, size: size.width - margins, margins: margins, drawLineTo: lines[m_blockType])
		let dashPattern : [CGFloat] = [ 4.0, 4.0]
		blockLines.lineWidth = 2
		blockLines.lineCapStyle = .round
		blockLines.setLineDash(dashPattern, count: 2, phase: 0.0)
		blockLines.stroke()

		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return image
	}
	
	private func DrawLine(_ bezier: UIBezierPath, size: CGFloat, margins: CGFloat, drawLineTo: DrawLineTo) {
		switch (drawLineTo) {
		case .bottom:
			bezier.move(to: CGPoint(x: margins, y: size))
			bezier.addLine(to: CGPoint(x: size, y: size))
		case .right:
			bezier.move(to: CGPoint(x: size, y: margins))
			bezier.addLine(to: CGPoint(x: size, y: size))
		case .both:
			DrawLine(bezier, size: size, margins: margins, drawLineTo: .bottom)
			DrawLine(bezier, size: size, margins: margins, drawLineTo: .right)
		case .none:
			break
		}
	}
}
