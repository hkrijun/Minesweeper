//
//  MenuOption.swift
//  Minesweeper
//
//  Created by Henri on 04/01/2018.
//  Copyright © 2018 Koulutus. All rights reserved.
//

import UIKit

class MenuOption : MenuObject {
	
	private var m_button : UIButton
	private var m_x : CGFloat = 0
	private var m_hidden : Bool = true
	private var m_hideDirection : HideDirection = .Left
	
	static var viewWidth : CGFloat = 0
	static var viewHeight : CGFloat = 0
	static let animDuration : Double = 0.25
	
	enum OptionType {
		case normal, back, exit
	}
	
	init(_ title: String, view: UIView) {
		m_button = UIButton()
		m_button.titleLabel?.font = UIFont(name: GraphicsManager.sharedInstance.graphicsFont!, size: 48) //UIFont.systemFont(ofSize: 48, weight: UIFontWeightBlack)
		Set(type: .normal)
		Set(title: title)
		
		view.addSubview(m_button)
	}
	
	deinit {
		m_button.removeFromSuperview()
	}
	
	func Set(type: OptionType) {
		var bgColor : UIColor
		var fgColor : UIColor
		
		switch (type) {
		case .normal:
			bgColor = UIColor(hue: 212/360, saturation: 0.73, brightness: 0.78, alpha: 1)
			fgColor = UIColor(hue: 126/360, saturation: 0.12, brightness: 0.92, alpha: 1)
		case .back:
			bgColor = UIColor(hue: 144/360, saturation: 0.73, brightness: 0.78, alpha: 1)
			fgColor = UIColor(hue: 143/360, saturation: 0.73, brightness: 1, alpha: 1)
		case .exit:
			bgColor = UIColor(hue: 351/360, saturation: 0.73, brightness: 0.78, alpha: 1)
			fgColor = UIColor(hue: 347/360, saturation: 0.73, brightness: 1, alpha: 1)
		}
		
		m_button.backgroundColor = bgColor
		m_button.setTitleColor(fgColor, for: .normal)
	}
	
	func Set(action: Selector, target: Any?) {
		m_button.addTarget(target, action: action, for: .touchUpInside)
	}
	
	func Set(title _title: String) {
		let title = _title.uppercased()
		
		m_button.setTitle(title, for: .normal)
		
		let textAttributes = [NSFontAttributeName: m_button.titleLabel!.font!]
		let textSize : CGSize = (title as NSString).size(attributes: textAttributes)
		
		m_button.frame.size = CGSize(width: textSize.width + 20, height: textSize.height)
	}
	
	func Set(pos: Pos) {
		m_x = pos.x
		m_button.frame.origin = pos.ToCGPoint()
	}
	
	func Set(hideDirection: HideDirection) {
		m_hideDirection = hideDirection
	}
	
	/// Change position with respect to hidden state
	func Changed(pos _pos: Pos, useBottomRightOrigo: Bool = false) {
		let pos = useBottomRightOrigo ? Pos(_pos.x - m_button.frame.width, _pos.y - m_button.frame.height) : _pos
		
		if m_hidden {
			m_x = pos.x
			m_button.frame.origin = CGPoint(x: MenuOption.viewWidth, y: pos.y)
		} else {
			Set(pos: pos)
		}
	}
	
	func GetHeight() -> CGFloat {
		return m_button.frame.height
	}
	
	func IsHidden() -> Bool {
		return m_hidden
	}
	
	func Hide(_ completion: ((Bool) -> Void)? = nil) {
		m_hidden = true
		self.m_button.frame.origin = CGPoint(x: hideDestinationPosition, y: self.m_button.frame.origin.y)
		_ = completion
	}
	
	func Hide(delay: Double, durationMultiplier: Double = 1, delayMultiplier: Double = 1, completion: ((Bool) -> Void)? = nil ) {
		m_hidden = true
		m_button.frame.origin.x = m_x
		
		UIView.animate(withDuration: MenuOption.animDuration * durationMultiplier, delay: delay * delayMultiplier, options: .curveEaseInOut, animations: {
			self.m_button.frame.origin = CGPoint(x: self.hideDestinationPosition, y: self.m_button.frame.origin.y)
		}, completion: completion)
	}
	
	func Show() {
		m_hidden = false
		m_button.frame.origin = CGPoint(x: self.m_x, y: self.m_button.frame.origin.y)
	}
	
	func Show(delay: Double) {
		m_hidden =  false
		m_button.frame.origin.x = showOriginPosition
		
		UIView.animate(withDuration: MenuOption.animDuration, delay: delay, options: .curveEaseInOut, animations: {
			self.m_button.frame.origin = CGPoint(x: self.m_x, y: self.m_button.frame.origin.y)
		}, completion: nil)
	}
	
	// -- Properties for Show() and Hide()
	
	private var hideDestinationPosition : CGFloat {
		get {
			return m_hideDirection == .Left ? -m_button.frame.width : MenuOption.viewWidth
		}
	}
	
	private var showOriginPosition : CGFloat {
		get {
			return m_hideDirection == .Left ? MenuOption.viewWidth : -m_button.frame.width
		}
	}
}

/*
class MenuButton: AnimatedMenuObject {
private var m_button: UIButton = UIButton()

override init() {
super.init()
Set(object: m_button)
}
}

class AnimatedMenuObject {
private var m_uiObject : UIControl?
private var m_x : CGFloat = 0
private var m_hidden : Bool = true

func Set(object: UIControl) {
m_uiObject = object
}

func Set(pos: Pos) {
m_x = pos.x
m_uiObject!.frame.origin = pos.ToCGPoint()
}

func Changed(pos: Pos) {
if m_hidden {
m_x = pos.x
m_uiObject!.frame.origin = CGPoint(x: MenuOption.viewWidth, y: pos.y)
} else {
Set(pos: pos)
}
}

func Hide(_ delay: Double = 0) {
m_hidden = true
UIView.animate(withDuration: MenuOption.animDuration, delay: delay, options: .curveEaseInOut, animations: {
self.m_uiObject!.frame.origin = CGPoint(x: MenuOption.viewWidth, y: self.m_uiObject!.frame.origin.y)
}, completion: nil)
}

func Show(_ delay: Double = 0) {
m_hidden = false
UIView.animate(withDuration: MenuOption.animDuration, delay: delay, options: .curveEaseInOut, animations: {
self.m_uiObject!.frame.origin = CGPoint(x: self.m_x, y: self.m_uiObject!.frame.origin.y)
}, completion: nil)
}
}
*/
