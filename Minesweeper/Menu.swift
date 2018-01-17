//
//  Menu.swift
//  Minesweeper
//
//  Created by Henri on 04/01/2018.
//  Copyright © 2018 Koulutus. All rights reserved.
//

import UIKit

protocol MenuObject {
	func Changed(pos: Pos, useBottomRightOrigo: Bool)
	func Show()
	func Show(delay: Double)
	//func Hide()
	func Hide(delay: Double, durationMultiplier: Double, delayMultiplier: Double, completion: ((Bool) -> Void)?)
	func Set(action: Selector, target: Any?)
	func GetHeight() -> CGFloat
	func IsHidden() -> Bool
	func Set(hideDirection: HideDirection)
}

class Menu {
	private var m_breadcrump : Breadcrump
	private var m_options : [MenuObject] = [MenuOption]()
	private let m_optionDelay : Double = 0.05
	private var m_backButton : MenuOption?
	private var m_parent : Menu?
	
	static var xPosition : CGFloat = 0 // For viewDidLoadSubViews events
	static var margins : CGFloat = 10
	
	var options : [MenuObject] {
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
	
	func Add(stats: [(name: String, score: String)], backButtonAction: Selector?, target: UIViewController) {
		m_options = [MenuStat]()
		var index : Int = 0
		
		for (name, score) in stats {
			m_options.append( MenuStat(title: score, value: name, view: target.view, fontSize: 32, colorScheme: .Scores) )
			m_options.last?.Set(hideDirection: index % 2 == 0 ? .Left : .Right)
			index += 1
		}
		
		if backButtonAction != nil {
			m_backButton!.Set(action: backButtonAction!, target: target)
		}
	}
	
	func Add(options: [(title: String, action: Selector)], backButtonAction: Selector?, target: UIViewController) {
		m_options = [MenuOption]()
		var index : Int = 0
		
		for (title, action) in options {
			m_options.append( MenuOption(title, view: target.view) )
			m_options.last?.Set(action: action, target: target)
			m_options.last?.Set(hideDirection: index % 2 == 0 ? .Left : .Right)
			index += 1
		}
		
		if backButtonAction != nil {
			m_backButton!.Set(action: backButtonAction!, target: target)
		}
	}
	
	func UpdateOptionPositions(breadcrump _breadcrump: Pos) {
		UpdateBreadcrumpPos(_breadcrump)
		
		var nextY = m_breadcrump.GetMaxPos().y + Menu.margins
		
		for option in m_options {
			option.Changed(pos: Pos(Menu.xPosition, nextY), useBottomRightOrigo: false)
			
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
		let animateBackButton = (parent == nil || menu.parent == nil)
		print( animateBackButton )
		
		Close(keepBreadcrump: isLowerMenu, animateBackButton: animateBackButton)
		menu.Open(skipAnimation: false, animateBackButton: animateBackButton)
	}
	
	func Open(skipAnimation: Bool = false, animateBackButton: Bool = true) {
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
			if animateBackButton {
				m_backButton!.Set(hideDirection: .Left)
				m_backButton!.Show(delay: Double(m_options.count) * m_optionDelay)
			} else {
				m_backButton!.Show()
			}
		}
	}
	
	func Close(keepBreadcrump: Bool, animateBackButton: Bool = true, durationMultiplier: Double = 1, delayMultiplier: Double = 1, completion: ((Bool) -> Void)? = nil ) { // Different approach, same result
		if !keepBreadcrump { m_breadcrump.Hide(durationMultiplier: durationMultiplier, delayMultiplier: delayMultiplier) }
		
		var delay : Double = m_optionDelay
		
		for option in m_options {
			option.Hide(delay: delay, durationMultiplier: durationMultiplier, delayMultiplier: delayMultiplier, completion: nil)
			delay += m_optionDelay
		}
		
		if m_backButton != nil {
			if animateBackButton {
				m_backButton!.Set(hideDirection: .Right)
				m_backButton!.Hide(delay: delay, durationMultiplier: durationMultiplier, delayMultiplier: delayMultiplier, completion: completion)
			} else {
				m_backButton!.Hide(completion)
			}
		}
	}
	
	func IsOpen() -> Bool {
		return !m_options.last!.IsHidden()
	}
}
