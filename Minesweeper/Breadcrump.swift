//
//  Breadcrump.swift
//  Minesweeper
//
//  Created by Henri on 04/01/2018.
//  Copyright © 2018 Koulutus. All rights reserved.
//

import UIKit

class Breadcrump {
	private var m_label = PaddedLabel()
	private var m_hidden : Bool = true
	private var m_x : CGFloat = 0
	
	init(_ title: String, view: UIView) {
		m_label.topInset = -5
		m_label.bottomInset = 0
		m_label.leftInset = 10
		m_label.rightInset = 10
		m_label.southbound = false
		m_label.lineBreakMode = .byClipping
		m_label.textAlignment = .center
		m_label.numberOfLines = 0
		
		m_label.font = UIFont(name: GraphicsManager.sharedInstance.graphicsFont!, size: 24)
		m_label.textColor = UIColor(hue: 48/360, saturation: 0.31, brightness: 0.85, alpha: 1)
		m_label.backgroundColor = UIColor(hue: 350/360, saturation: 0.93, brightness: 0.8, alpha: 1)
		
		Set(title: title)
		view.addSubview(m_label)
	}
	
	deinit {
		m_label.removeFromSuperview()
	}
	
	func Set(pos: Pos) {
		m_x = pos.x
		m_label.frame.origin = CGPoint(x: pos.x, y: pos.y - m_label.frame.height * 0.5) // pos.ToCGPoint()
	}
	
	func Changed(pos: Pos) {
		if m_hidden {
			m_x = pos.x
			m_label.frame.origin = CGPoint(x: MenuOption.viewWidth, y: pos.y - m_label.frame.height * 0.5)
		} else {
			Set(pos: pos)
		}
	}
	
	func GetPos() -> Pos {
		return Pos(m_label.frame.minX, m_label.frame.minY + m_label.frame.height * 0.5)
	}
	
	func GetMaxPos() -> Pos {
		return Pos(m_label.frame.maxX, m_label.frame.maxY)
	}
	
	func Set(title: String) {
		m_label.text = title
		
		let textAttributes = [NSFontAttributeName: m_label.font!]
		let textSize : CGSize = (title as NSString).size(attributes: textAttributes)
		
		m_label.frame.size = CGSize(width: textSize.width + 24, height: textSize.height + 10)
	}
	
	func Hide(_ delay: Double = 0, durationMultiplier: Double = 1, delayMultiplier: Double = 1) {
		m_hidden = true
		UIView.animate(withDuration: MenuOption.animDuration * durationMultiplier, delay: delay * delayMultiplier, options: .curveEaseInOut, animations: {
			self.m_label.frame.origin = CGPoint(x: MenuOption.viewWidth, y: self.m_label.frame.origin.y)
		}, completion: nil)
	}
	
	func Show(_ delay: Double = 0) {
		m_hidden = false
		UIView.animate(withDuration: MenuOption.animDuration, delay: delay, options: .curveEaseInOut, animations: {
			self.m_label.frame.origin = CGPoint(x: self.m_x, y: self.m_label.frame.origin.y)
		}, completion: nil)
	}
}
