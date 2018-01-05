//
//  AnimateValue.swift
//  Minesweeper
//
//  Created by Koulutus on 22/11/2017.
//  Copyright © 2017 Koulutus. All rights reserved.
//

import Foundation

class AnimateValue {
	private var m_ready : Bool = false
	private var m_current : Double = 0
	private var m_target : Double = 0
	
	private var m_minSpeedMultiplier : Double = 0.025
	private var m_maxChangeValue : Double = 200
	private var m_changeSpeed : Double = 200
	
	func Animate(deltaTime: Double) -> Bool {
		if !m_ready {
			let fraction : Double = min(1, abs(m_current - m_target) / m_maxChangeValue)
			let change : Double = max(m_minSpeedMultiplier, (1 - pow(1 - fraction, 4))) * deltaTime * m_changeSpeed
			
			if m_current + change < m_target {
				m_current += change
			} else if m_current - change > m_target {
				m_current -= change
			} else {
				m_current = m_target
				m_ready = true
			}
		} else {
			return false
		}
		
		return true
	}
	
	func Update(target: Double) {
		m_target = target
		m_ready = false
	}
	
	func Update(current: Double) {
		m_current = current
	}
	
	func GetValue() -> Double {
		return m_current
	}
}
