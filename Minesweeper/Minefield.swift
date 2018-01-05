//
//  Minefield.swift
//  Minesweeper
//
//  Created by Koulutus on 27/09/2017.
//  Copyright © 2017 Koulutus. All rights reserved.
//

import Foundation
import UIKit

protocol MinefieldDelegate {
	func BlockClicked(_ block: Block)
	func RemainingBlockCountChanged(clearBlocks: Int, mines: Int)
	func HitBomb()
}

class Minefield: GameViewControllerDelegate {
	var m_minefieldDelegate : MinefieldDelegate?
	var m_perlin : PerlinGenerator = PerlinGenerator()
	var m_minePlantingLikeliness : Float = 0.2
	
	var m_block : [[Block]] = []
	
	var m_sizeX : Int
	var m_sizeY : Int
	var m_tileWidth : Int
	var m_tileHeight : Int
	
	var m_marginTop : Int = 100
	var m_marginSides : Int = 100
	
	// -- Minefield internal
	
	var m_clearBlocks : Int = 0
	var m_mineCount : Int = 0
	
	var m_blocksBeingOpenedCount = 0
	var m_mysteryBlocksToUpdate = [Location]()
	var m_openBlockQueue = [Location]()
	var m_openBlockQueueProcessed : Int = -1
	
	// init(,,,,)
	// Makes minefield fit inside set width and height
	
	init(_ minefieldWidth: Int, _ minefieldHeight: Int, _ tileWidth: Int, _ tileHeight: Int ) {
		m_tileWidth = tileWidth
		m_tileHeight = tileHeight
		
		m_sizeX = (minefieldWidth - m_marginSides * 2) / tileWidth
		m_sizeY = (minefieldHeight - m_marginTop - m_marginSides) / tileHeight
		
		m_marginSides = (minefieldWidth - m_sizeX * tileWidth) / 2

		InitEmptyField()
	}
	
	func SetParameters(width minefieldWidth: Int, height minefieldHeight: Int, blockSize: Int ) {
		m_tileWidth = blockSize
		m_tileHeight = blockSize
		
		m_sizeX = (minefieldWidth - m_marginSides * 2) / blockSize
		m_sizeY = (minefieldHeight - m_marginTop - m_marginSides) / blockSize
		
		m_marginSides = (minefieldWidth - m_sizeX * blockSize) / 2
		
		InitEmptyField()
	}
	
	// -- Initialises Mine-object array(s)
	
	func InitEmptyField() {
		m_mysteryBlocksToUpdate.removeAll()
		m_block.removeAll()
		
		for x in 0..<m_sizeX {
			m_block.append([Block]())
			
			for y in 0..<m_sizeY {
				m_block[x].append(Block(self, Location(x, y), m_marginSides + x * m_tileWidth, m_marginTop + y * m_tileHeight, m_tileWidth, m_tileHeight))
			}
		}
	}
	
	// -- Creates minefield
	
	func Create(_ view: UIView, delegate: MinefieldDelegate? = nil) {
		if delegate != nil {
			m_minefieldDelegate = delegate!
		}
		
		SetupPerlin(octaves: 14, persistence: 0.9, zoom: 10)
		
		m_clearBlocks = m_sizeX * m_sizeY
		m_mineCount = 0
		
		for x in 0..<m_sizeX {
			for y in 0..<m_sizeY {
				let perlinVal = abs(m_perlin.perlinNoise(Float(x), y: Float(y), z: 0, t: 0))
				
				if( perlinVal > 0.5 - m_minePlantingLikeliness && perlinVal < 0.5 + m_minePlantingLikeliness ) {
					BlockAt(x, y).PlantBomb()
					m_mineCount += 1
					
					for nearX in -1...1 {
						for nearY in -1...1 {
							let markX = x + nearX
							let markY = y + nearY
							
							if( markX >= 0 && markX < m_sizeX && markY >= 0 && markY < m_sizeY ) {
								BlockAt(markX, markY).SetNearBombLocation(x: nearX, y: nearY) // Marks surrounding blocks to have a bomb nearby
							}
						}
					}
				}
				
				if (x == 0 && (y == 0 || y == m_sizeY - 1)) || (x == m_sizeX - 1 && (y == 0 || y == m_sizeY - 1)) { // Corners
					BlockAt(x, y).SolveBlockType()
				}
				
				view.addSubview(BlockAt(x, y).m_button)
				view.sendSubview(toBack: BlockAt(x, y).m_button)
			}
		}
		
		m_clearBlocks -= m_mineCount
		UpdateBlocks()
	}
	
	// -- Calls minefield blocks to update their appearance
	
	func UpdateBlocks() {
		for x in 0..<m_sizeX {
			for y in 0..<m_sizeY {
				BlockAt(x, y).UpdateAppearance()
			}
		}

		m_minefieldDelegate?.RemainingBlockCountChanged(clearBlocks: m_clearBlocks, mines: m_mineCount)
	}
	
	// -- Minefield manipulation calls
	
	func CheckBlock(_ location: Location) {
		if BlockAt(location).IsBomb() {
			RevealBombs()
		} else {
			OpenBlock(location)
		}
	}
	
	func ToggleFlag(_ location: Location) {
		BlockAt(location).ToggleFlag()
	}
	
	func OpenBlock(_ location: Location) {
		m_blocksBeingOpenedCount += 1
		
		if BlockAt(location).IsOpenable() {
			//BlockAt(location).Open()
			BlockAt(location).MarkOpen()
			m_openBlockQueue.append(location)
			
			m_clearBlocks -= 1
			
			if location.x - 1 >= 0 {
				OpenBlock(Location(location.x - 1 , location.y))
			}
			if location.x + 1 < m_sizeX {
				OpenBlock(Location(location.x + 1, location.y))
			}
			if location.y - 1 >= 0 {
				OpenBlock(Location(location.x, location.y - 1))
			}
			if location.y + 1 < m_sizeY {
				OpenBlock(Location(location.x, location.y + 1))
			}
		} else if Valid(location: location) {
			m_mysteryBlocksToUpdate.append(location)
		}
		
		m_blocksBeingOpenedCount -= 1
		
		if m_blocksBeingOpenedCount == 0 {
			//UpdateMysteryBlocks()
			m_openBlockQueueProcessed = 0
			m_minefieldDelegate!.RemainingBlockCountChanged(clearBlocks: m_clearBlocks, mines: m_mineCount)
		}
	}
	
	// -- OpenBlock aux
	
	/// Used to update graphics/edges of opened blocks
	private func UpdateMysteryBlocks() {
		for i in 0..<m_mysteryBlocksToUpdate.count {
			BlockAt(m_mysteryBlocksToUpdate[i]).SolveBlockType()
			BlockAt(m_mysteryBlocksToUpdate[i]).UpdateAppearance()
		}
		
		m_mysteryBlocksToUpdate.removeAll()
	}
	
	func RevealBombs() {
		for x in 0..<m_sizeX {
			for y in 0..<m_sizeY {
				BlockAt(x, y).RevealBomb()
			}
		}
		
		for x in 0..<m_sizeX {
			for y in 0..<m_sizeY {
				BlockAt(x, y).SolveBlockType()
				BlockAt(x, y).UpdateAppearance()
			}
		}
		
		m_minefieldDelegate?.HitBomb()
	}

	// -- Delegate ran
	
	func FrameUpdate(deltaTime: Double) {
		let queueSize : Int = m_openBlockQueue.count
		
		if m_openBlockQueueProcessed > -1 {
			let speed : Int = 1 + m_openBlockQueueProcessed
			
			for _ in 1...min(queueSize, speed) {
				BlockAt(m_openBlockQueue.first!).Open()
				m_openBlockQueue.removeFirst()
				m_openBlockQueueProcessed += 1
			}
			
			if m_openBlockQueue.count == 0 {
				m_openBlockQueueProcessed = -1
				UpdateMysteryBlocks()
			}
		}
	}
	
	// -- Utility
	
	func GetFieldSize() -> (width: CGFloat, height: CGFloat) {
		return (width: CGFloat(m_sizeX * m_tileWidth + m_marginSides * 2), height: CGFloat(m_sizeY * m_tileWidth + m_marginSides + m_marginTop))
	}
	
	func BlockAt(_ x: Int, _ y: Int) -> Block {
		return m_block[x][y]
	}
	
	func BlockAt(_ location: Location) -> Block {
		return m_block[location.x][location.y]
	}
	
	func Valid(location: Location) -> Bool {
		return location.x >= 0 && location.x < m_sizeX && location.y >= 0 && location.y < m_sizeY
	}
	
	func GetState() -> (total: Int, left: Int) {
		return (total: m_sizeX * m_sizeY, left: m_clearBlocks)
	}
	
	func SetupPerlin(octaves: Int, persistence: Float, zoom: Float) {
		m_perlin = PerlinGenerator()
		m_perlin.octaves = octaves
		m_perlin.persistence = persistence
		m_perlin.zoom = zoom
	}
	
}
