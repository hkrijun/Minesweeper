//
//  Mine.swift
//  Minesweeper
//
//  Created by Koulutus on 31/10/2017.
//  Copyright © 2017 Koulutus. All rights reserved.
//

import Foundation
import UIKit

class Block {
 	var m_button : UIButton
	var m_location : Location
	
	private var m_threatLevel : Int = 0
	private var m_isBomb : Bool = false
	private var m_markedOpen : Bool = false
	private var m_size : CGFloat = 0
	private var m_appearance : MineAppearance = .Mystery
	private var m_minefield : Minefield
	
	private var m_bombLocations : [Bool] = [false, false, false, false, false, false, false, false] // Clockwise starting from top left
	private var m_blockType : RiddlerGraphic.BlockType = .surrounded
	
 	enum NearLocation : Int {
		case topLeft = 0, top, topRight, right, bottomRight, bottom, bottomLeft, left
	}

	private func BombLocation(_ bombLocation: NearLocation) -> Int {
		return bombLocation.rawValue
	}
	
	init(_ minefield: Minefield, _ location: Location, _ posX: Int, _ posY: Int, _ sizeX: Int, _ sizeY: Int) {
		m_minefield = minefield
		m_location = location
		m_size = CGFloat(sizeX)
		m_button = UIButton(frame: CGRect(x: posX, y: posY, width: sizeX, height: sizeY))
		m_button.addTarget(self, action: #selector(Clicked), for: .touchUpInside)

		//let threatFont = UIFont(name: GraphicsManager.sharedInstance.graphicsFont!, size: 20)
		m_button.titleLabel?.font = UIFont.systemFont(ofSize: m_size * 0.35, weight: UIFontWeightBold)
	}
	
	deinit {
		m_button.removeFromSuperview()
	}
	
	/// Matrix relative to position where top left is (-1, -1)
	func SetNearBombLocation(x: Int, y: Int, value: Bool = true) {
		if y == -1 { // 0 - 2
			m_bombLocations[x + 1] = value
		} else if y == 0 && x != 0 { // 3, 7
			m_bombLocations[x == -1 ? 7 : 3] = value
		} else if y == 1 { // 4 - 6
			m_bombLocations[6 - (x + 1)] = value
		}
		
		IncreaseThreatLevel()
	}
	
	func HasBombIn(nearLocation: NearLocation) -> Bool {
		return m_bombLocations[ nearLocation.rawValue ]
	}
	
	func Position() -> Pos {
		return Pos(m_button.frame.origin.x, m_button.frame.origin.y)
	}
	
	@objc func Clicked() {
		m_minefield.m_minefieldDelegate?.BlockClicked(self)
	}
	
	func PlantBomb() {
		//m_appearance = .Bomb // DEBUG: shows bombs
		m_isBomb = true
	}
	
	func IsBomb() -> Bool {
		return m_isBomb
	}
	
	private func IncreaseThreatLevel() {
		m_threatLevel += 1
	}
	
	func SolveBlockType() {
		if AppearsBombBlock() {
			SolveBombBlockType()
		} else {
			SolveRiddlerBlockType()
		}
	}
	
	private func SolveRiddlerBlockType() {
		SolveBlockType(solver: { x, y in return self.m_minefield.BlockAt(x, y).AppearsBlock() } )
	}
	
	private func SolveBombBlockType() {
		SolveBlockType(solver: { x, y in return self.m_minefield.BlockAt(x, y).AppearsBombBlock() } )
	}
	
	private func SolveBlockType(solver: (Int, Int) -> Bool) {
		var mysteries = [NearLocation]()
		
		if m_location.y - 1 >= 0 && solver(m_location.x, m_location.y - 1) {
			mysteries.append(.top)
		}
		if m_location.y + 1 < m_minefield.m_sizeY && solver(m_location.x, m_location.y + 1) {
			mysteries.append(.bottom)
		}
		if m_location.x - 1 >= 0 && solver(m_location.x - 1, m_location.y) {
			mysteries.append(.left)
		}
		if m_location.x + 1 < m_minefield.m_sizeX && solver(m_location.x + 1, m_location.y) {
			mysteries.append(.right)
		}

		switch (mysteries.count) {
		case 1:
			if mysteries.contains(.top) {
				m_blockType = .bottomEnd
			} else if mysteries.contains(.right) {
				m_blockType = .leftEnd
			} else if mysteries.contains(.bottom) {
				m_blockType = .topEnd
			} else {
				m_blockType = .rightEnd
			}
		case 2:
			if mysteries.contains(.top) {
				if mysteries.contains(.left) {
					m_blockType = .bottomRightCorner
				} else if mysteries.contains(.right) {
					m_blockType = .bottomLeftCorner
				}
			} else if mysteries.contains(.bottom) {
				if mysteries.contains(.left) {
					m_blockType = .topRightCorner
				} else if mysteries.contains(.right) {
					m_blockType = .topLeftCorner
				}
			}
		case 3, 4:
			m_blockType = .surrounded
		default:
			m_blockType = .lone
		}
	}
	
	func UpdateAppearance() {
		var foregroundImage : UIImage?
		var backgroundImage : UIImage?
		
		switch m_appearance {
		case .Bomb:
			foregroundImage = GraphicsManager.sharedInstance.bombGraphic
			backgroundImage = GraphicsManager.sharedInstance.bombTileGraphic[m_blockType.rawValue]
		case .Mystery:
			backgroundImage = GraphicsManager.sharedInstance.riddlerGraphic[m_blockType.rawValue]
		case .Open:
			if m_threatLevel > 0 {
				backgroundImage = GraphicsManager.sharedInstance.cluedoGraphic[m_threatLevel]
			}
		case .Flag:
			backgroundImage = GraphicsManager.sharedInstance.riddlerGraphic[m_blockType.rawValue]
			foregroundImage = GraphicsManager.sharedInstance.buttonFlagGraphic
		}

		m_button.setImage(foregroundImage, for: .normal)
		m_button.setBackgroundImage(backgroundImage, for: UIControlState.normal)
	}
	
	func MarkOpen() {
		m_markedOpen = true
	}
	
	func Open() {
		m_appearance = IsBomb() ? .Bomb : .Open
		UpdateAppearance()
	}
	
	func RevealBomb() {
		if IsBomb() {
			m_appearance = .Bomb
		}
	}
	
	func ToggleFlag() {
		if m_appearance == .Mystery {
			m_appearance = .Flag
			UpdateAppearance()
		} else if m_appearance == .Flag {
			m_appearance = .Mystery
			UpdateAppearance()
		}
	}
	
	func HasFlag() -> Bool {
		return m_appearance == .Flag
	}
	
	func IsOpenable() -> Bool {
		return m_appearance != .Open && !IsBomb() && !m_markedOpen
	}
	
	func IsMystery() -> Bool {
		return m_appearance == .Mystery || m_appearance == .Flag
	}
	
	func AppearsBombBlock() -> Bool {
		return m_appearance == .Bomb
	}
	
	func AppearsBlock() -> Bool {
		return m_appearance == .Mystery || m_appearance == .Flag // || m_appearance == .Bomb
	}
	
}
