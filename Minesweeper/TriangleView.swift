// Triangle for the in-game UI

import UIKit

@IBDesignable
class TriangleView : UIView {
	
	@IBInspectable var triangleColor : UIColor = UIColor(hue: 203/360.0, saturation: 0.35, brightness: 0.15, alpha: 0.33)
	@IBInspectable var positionTop : Bool = true
	@IBInspectable var positionLeft : Bool = true

	enum TrianglePosition {
		case upLeft, bottomRight
	}
	
	override func draw(_ rect: CGRect) {
		guard let context = UIGraphicsGetCurrentContext() else { return }
		
		context.beginPath()
		
		if positionTop {
			context.move(to: CGPoint(x: rect.minX, y: rect.minY))
			context.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
			
			if positionLeft {
				context.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
			} else {
				context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
			}
		} else {
			context.move(to: CGPoint(x: rect.maxX, y: rect.maxY))
			context.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
			
			if positionLeft {
				context.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
			} else {
				context.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
			}
		}
		
		context.closePath()
		
		context.setFillColor(triangleColor.cgColor)
		context.fillPath()
	}
}
