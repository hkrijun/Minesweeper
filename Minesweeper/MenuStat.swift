//
//  MenuStat.swift
//  Minesweeper
//
//  Created by Henri on 11/01/2018.
//  Copyright © 2018 Koulutus. All rights reserved.
//

import UIKit

class MenuStat : MenuObject {
	
	private let VALUE : Int = 0
	private let TITLE : Int = 1
	
	private var m_label = [PaddedLabel]()
	private var m_x : CGFloat = 0
	private var m_hidden : Bool = true
	private var m_hideDirection : HideDirection = .Left
	
	enum ColorScheme {
		case Stats, Scores
	}
	
	private var hidePosition : CGFloat {
		get {
			return m_hideDirection == .Left ? -self.GetWidth() : MenuOption.viewWidth
		}
	}
	
	init(title: String, value: String, view: UIView, fontSize: CGFloat = 26, colorScheme: ColorScheme = .Stats) {
		m_label.append( PaddedLabel(frame: CGRect.zero) )
		m_label.append( PaddedLabel(frame: CGRect.zero) )
		
		m_label[TITLE].textAlignment = .right
		m_label[VALUE].textAlignment = .left
		
		for label in m_label {
			label.leftInset = 10
			label.rightInset = 10
			label.topInset = -15
			label.bottomInset = -15
			label.southbound = false
			label.lineBreakMode = .byClipping
			label.numberOfLines = 0
			label.font = UIFont(name: GraphicsManager.sharedInstance.graphicsFont!, size: fontSize)

			view.addSubview(label)
		}
		
		Set(colorScheme: colorScheme)
		Set(title: title, label: TITLE)
		Set(title: value, label: VALUE)
	}
	
	deinit {
		for label in m_label {
			label.removeFromSuperview()
		}
	}
	
	func Set(colorScheme: ColorScheme) {
		switch (colorScheme) {
		case .Stats:
			m_label[TITLE].backgroundColor = UIColor(hue: 202/360, saturation: 0.16, brightness: 0.1, alpha: 1)
			m_label[TITLE].textColor = UIColor(hue: 213/360, saturation: 0.3, brightness: 0.21, alpha: 1)
			
			m_label[VALUE].backgroundColor = UIColor(hue: 200/360, saturation: 0.24, brightness: 0.13, alpha: 1)
			m_label[VALUE].textColor = UIColor(hue: 213/360, saturation: 0.32, brightness: 0.32, alpha: 1)
		case .Scores:
			/*m_label[TITLE].backgroundColor = UIColor(hue: 350/360, saturation: 0.26, brightness: 0.16, alpha: 1)
			m_label[TITLE].textColor = UIColor(hue: 348/360, saturation: 0.25, brightness: 0.28, alpha: 1)
			
			m_label[VALUE].backgroundColor = UIColor(hue: 350/360, saturation: 0.23, brightness: 0.27, alpha: 1)
			m_label[VALUE].textColor = UIColor(hue: 56/360, saturation: 0.22, brightness: 0.54, alpha: 1)*/
			m_label[TITLE].backgroundColor = UIColor(hue: 216/360, saturation: 0.12, brightness: 0.92, alpha: 1)
			m_label[TITLE].textColor = UIColor(hue: 212/360, saturation: 0.73, brightness: 0.78, alpha: 1)
			
			m_label[VALUE].backgroundColor = UIColor(hue: 212/360, saturation: 0.73, brightness: 0.78, alpha: 1)
			m_label[VALUE].textColor = UIColor(hue: 216/360, saturation: 0.12, brightness: 0.92, alpha: 1)
			
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
	
	/// useBottomRightOrigo unimplemented
	func Changed(pos: Pos, useBottomRightOrigo: Bool = false) {
		if m_hidden {
			m_x = pos.x
			Set(framePos: Pos(hidePosition, pos.y))
		} else {
			Set(pos: pos)
		}
		
		while m_x + GetWidth() > MenuOption.viewWidth {
			Set(title: m_label[VALUE].text!.substring(to: m_label[VALUE].text!.index(before: m_label[VALUE].text!.endIndex)), label: VALUE) // Removes last char
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
	
	func GetWidth() -> CGFloat {
		return m_label.first!.frame.width + m_label.last!.frame.width
	}
	
	func IsHidden() -> Bool {
		return m_hidden
	}
	
	func Set(title: String, label: Int) {
		m_label[label].text = title
		
		let textAttributes = [NSFontAttributeName: m_label[label].font!]
		let textSize : CGSize = (title as NSString).size(attributes: textAttributes)
		
		m_label[label].frame.size = CGSize(width: textSize.width + m_label[label].leftInset + m_label[label].rightInset, height: textSize.height)
	}
	
	func Set(hideDirection: HideDirection) {
		m_hideDirection = hideDirection
	}
	
	/// Unused
	func Set(action: Selector, target: Any?) {
		print( "MenuStat.Set(action: Selector, target: Any?) IS UNUSED" )
	}
	
	func Hide() {
		m_hidden = true
		Set(pos: Pos(hidePosition, m_label.first!.frame.origin.y))
	}
	
	func Hide(_ delay: Double = 0) {
		Hide(delay: delay)
	}
	
	func Hide(delay: Double = 0, durationMultiplier: Double = 1, delayMultiplier: Double = 1, completion: ((Bool) -> Void)? = nil ) {
		m_hidden = true
		UIView.animate(withDuration: MenuOption.animDuration * durationMultiplier, delay: delay * delayMultiplier, options: .curveEaseInOut, animations: {
			self.Set(framePos: Pos(self.hidePosition, self.m_label.first!.frame.origin.y))
		}, completion: completion)
	}
	
	func Show() {
		m_hidden = false
		Set(pos: Pos(m_x, m_label.first!.frame.origin.y))
	}
	
	func Show(_ delay: Double = 0) {
		Show(delay: delay)
	}
	
	func Show(delay: Double = 0) {
		m_hidden = false
		UIView.animate(withDuration: MenuOption.animDuration, delay: delay, options: .curveEaseInOut, animations: {
			self.Set(framePos: Pos(self.m_x, self.m_label.first!.frame.origin.y))
		}, completion: nil)
	}
	
}
