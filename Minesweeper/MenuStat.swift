//
//  MenuStat.swift
//  Minesweeper
//
//  Created by Henri on 11/01/2018.
//  Copyright © 2018 Koulutus. All rights reserved.
//

import UIKit

class MenuStat {
	
	private let VALUE : Int = 0
	private let TITLE : Int = 1
	
	private var m_label = [PaddedLabel]()
	private var m_x : CGFloat = 0
	private var m_hidden : Bool = true
	
	init(title: String, value: String, view: UIView) {
		m_label.append( PaddedLabel(frame: CGRect.zero) )
		m_label.append( PaddedLabel(frame: CGRect.zero) )
		
		m_label[TITLE].leftInset = 0
		m_label[TITLE].rightInset = 5
		m_label[TITLE].textAlignment = .right
		m_label[TITLE].backgroundColor = UIColor(hue: 350/360, saturation: 0.93, brightness: 0.62, alpha: 1)
		
		m_label[VALUE].leftInset = 5
		m_label[VALUE].rightInset = 0
		m_label[VALUE].textAlignment = .left
		m_label[VALUE].backgroundColor = UIColor(hue: 350/360, saturation: 0.93, brightness: 0.8, alpha: 1)
		
		for label in m_label {
			label.topInset = -15
			label.bottomInset = -15
			label.southbound = false
			label.lineBreakMode = .byClipping
			label.numberOfLines = 0
			label.font = UIFont(name: GraphicsManager.sharedInstance.graphicsFont!, size: 26)
			label.textColor = UIColor(hue: 48/360, saturation: 0.31, brightness: 0.85, alpha: 1)

			view.addSubview(label)
		}
		
		Set(title: title, label: TITLE)
		Set(title: value, label: VALUE)
	}
	
	deinit {
		for label in m_label {
			label.removeFromSuperview()
		}
	}
	
	func Set(width: CGFloat, firstElement: CGFloat = 0.25) {
		m_label.first!.frame.size.width = width * firstElement
		m_label.last!.frame.size.width = width * (1 - firstElement)
		m_label.last!.frame.origin.x = m_label.first!.frame.maxX
	}
	
	func Set(pos: Pos) {
		m_x = pos.x
		Set(framePos: pos)
	}
	
	private func Set(framePos pos: Pos) {
		m_label[0].frame.origin = CGPoint(x: pos.x, y: pos.y)
		m_label[1].frame.origin = CGPoint(x: pos.x + m_label[0].frame.width, y: pos.y)
	}
	
	func Changed(pos: Pos) {
		if m_hidden {
			m_x = pos.x
			Set(framePos: Pos(MenuOption.viewWidth, pos.y))
		} else {
			Set(pos: pos)
		}
	}
	
	func GetPos() -> Pos {
		return Pos(m_label.first!.frame.minX, m_label.first!.frame.minY)
	}
	
	func GetMaxPos() -> Pos {
		return Pos(m_label.last!.frame.maxX, m_label.last!.frame.maxY)
	}
	
	func GetHeight() -> CGFloat {
		return m_label.first!.frame.height
	}
	
	func Set(title: String, label: Int) {
		m_label[label].text = title
		
		let textAttributes = [NSFontAttributeName: m_label[label].font!]
		let textSize : CGSize = (title as NSString).size(attributes: textAttributes)
		
		m_label[label].frame.size = CGSize(width: textSize.width + 24, height: textSize.height)
	}
	
	func Hide(_ delay: Double = 0, durationMultiplier: Double = 1, delayMultiplier: Double = 1) {
		m_hidden = true
		UIView.animate(withDuration: MenuOption.animDuration * durationMultiplier, delay: delay * delayMultiplier, options: .curveEaseInOut, animations: {
			self.Set(framePos: Pos(MenuOption.viewWidth, self.m_label.first!.frame.origin.y))
		}, completion: nil)
	}
	
	func Show(_ delay: Double = 0) {
		m_hidden = false
		UIView.animate(withDuration: MenuOption.animDuration, delay: delay, options: .curveEaseInOut, animations: {
			self.Set(framePos: Pos(self.m_x, self.m_label.first!.frame.origin.y))
		}, completion: nil)
	}
	
}
