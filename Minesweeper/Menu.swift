//
//  Menu.swift
//  Minesweeper
//
//  Created by Henri on 04/01/2018.
//  Copyright © 2018 Koulutus. All rights reserved.
//

import UIKit

class OptionList {
	var title : String
	var action : Selector
	
	init(_ title: String, _ action: Selector) {
		self.title = title
		self.action = action
	}
}

class Menu {
	private var m_breadcrump : Breadcrump
	private var m_options : [MenuOption] = [MenuOption]()
	private let m_optionDelay : Double = 0.1
	private var m_backButton : MenuOption?
	private var m_parent : Menu?
	
	static var xPosition : CGFloat = 0 // For viewDidLoadSubViews events
	static var margins : CGFloat = 10
	
	var options : [MenuOption] {
		get { return m_options }
		set(value) { m_options = value }
	}
	
	var parent : Menu? {
		get { return m_parent }
		set(value) { m_parent = value }
	}
	
	init(_ breadcrump: String, backButton: String?, backButtonType: MenuOption.OptionType?, view: UIView) {
		m_breadcrump = Breadcrump(breadcrump, view: view)
		
		if backButton != nil {
			m_backButton = MenuOption(backButton!, view: view)
			m_backButton!.Set(type: backButtonType ?? .normal)
		}
	}
	
	func RemoveAllOptions() {
		m_options.removeAll()
	}
	
	func Add(options: [(title: String, action: Selector)], backButtonAction: Selector?, target: UIViewController) {
		for (title, action) in options {
			m_options.append( MenuOption(title, view: target.view) )
			m_options.last?.Set(action: action, target: target)
		}
		
		if backButtonAction != nil {
			m_backButton!.Set(action: backButtonAction!, target: target)
		}
	}
	
	func UpdateOptionPositions(breadcrump _breadcrump: Pos) {
		UpdateBreadcrumpPos(_breadcrump)
		
		var nextY = m_breadcrump.GetMaxPos().y + Menu.margins
		
		for option in m_options {
			option.Changed(pos: Pos(Menu.xPosition, nextY))
			
			nextY += option.GetHeight() + Menu.margins
		}
		
		if m_backButton != nil {
			m_backButton!.Changed(pos: Pos(MenuOption.viewWidth - 20, MenuOption.viewHeight - 20), useBottomRightOrigo: true)
		}
	}
	
	func UpdateBreadcrumpPos(_ _breadcrump: Pos? = nil) {
		let breadcrump : Pos? = m_parent != nil ? Pos(m_parent!.GetBreadcrumpMaxes().x + Menu.margins, m_parent!.m_breadcrump.GetPos().y) : _breadcrump
		
		if breadcrump != nil {
			m_breadcrump.Changed(pos: breadcrump!)
		}
	}
	
	func GetBreadcrumpMaxes() -> Pos {
		return m_breadcrump.GetMaxPos()
	}
	
	func SwitchTo(menu: Menu, isLowerMenu: Bool) {
		Close(keepBreadcrump: isLowerMenu)
		menu.Open()
	}
	
	func Open(skipAnimation: Bool = false) {
		UpdateBreadcrumpPos()
		m_breadcrump.Show()
		
		for i in 0..<m_options.count {
			let option = m_options[i]
			
			if skipAnimation {
				option.Show()
			} else {
				option.Show(delay: Double(1 + i) * m_optionDelay)
			}
		}
		
		if m_backButton != nil {
			m_backButton!.Show(delay: 0) // Double(m_options.count) * m_optionDelay)
		}
	}
	
	func Close(keepBreadcrump: Bool, durationMultiplier: Double = 1, delayMultiplier: Double = 1, completion: @escaping (Bool) -> Void = { _ in } ) { // Different approach, same result
		if !keepBreadcrump { m_breadcrump.Hide(durationMultiplier: durationMultiplier, delayMultiplier: delayMultiplier) }
		
		var delay : Double = m_optionDelay
		
		for option in m_options {
			option.Hide(delay: delay, durationMultiplier: durationMultiplier, delayMultiplier: delayMultiplier)
			delay += m_optionDelay
		}
		
		if m_backButton != nil {
			m_backButton!.Hide(delay: 0, durationMultiplier: durationMultiplier, delayMultiplier: delayMultiplier, completion: completion)
		}
	}
	
	func IsOpen() -> Bool {
		return !m_options.last!.m_hidden
	}
}
