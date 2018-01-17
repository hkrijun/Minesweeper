//
//  DataTypes.swift
//  Minesweeper
//
//  Created by Koulutus on 31/10/2017.
//  Copyright © 2017 Koulutus. All rights reserved.
//

import UIKit

struct Location {
	var x : Int
	var y : Int
	
	init(_ x: Int = 0, _ y : Int = 0) {
		self.x = x
		self.y = y
	}
}

struct Pos {
	var x : CGFloat
	var y : CGFloat
	
	init() {
		self.x = 0
		self.y = 0
	}
	
	init(_ xy: CGFloat = 0) {
		self.x = xy
		self.y = xy
	}
	
	init(_ x: CGFloat = 0, _ y: CGFloat = 0) {
		self.x = x
		self.y = y
	}
	
	init(x: CGFloat = 0, y: CGFloat = 0) {
		self.x = x
		self.y = y
	}
	
	init(x: CGFloat) {
		self.x = x
		self.y = 0
	}
	
	init(y: CGFloat) {
		self.x = 0
		self.y = y
	}
	
	init(_ cgSize: CGSize) {
		self.x = cgSize.width
		self.y = cgSize.height
	}
	
	init(_ cgPoint: CGPoint) {
		self.x = cgPoint.x
		self.y = cgPoint.y
	}
	
	func ToCGPoint() -> CGPoint {
		return CGPoint(x: self.x, y: self.y)
	}
	
	static func +(first: Pos, second: Pos) -> Pos {
		return Pos(first.x + second.x, first.y + second.y)
	}
	
	static func +(first: Pos, second: CGSize) -> Pos {
		return Pos(first.x + second.width, first.y + second.height)
	}
	
	static func -(first: Pos, second: Pos) -> Pos {
		return Pos(first.x - second.x, first.y - second.y)
	}
	
	static func -(first: Pos, second: CGSize) -> Pos {
		return Pos(first.x - second.width, first.y - second.height)
	}
	
	static func *(first: Pos, second: CGFloat) -> Pos {
		return Pos(first.x * second, first.y * second)
	}
	
	func Magnitude() -> CGFloat {
		return sqrt( pow(self.x, 2) + pow(self.y, 2) )
	}
	
	func Normalized() -> Pos {
		let magnitude = self.Magnitude()
		
		return Pos( self.x / magnitude, self.y / magnitude)
	}
}

enum MineAppearance {
	case Mystery, Open, Bomb, Flag
}

enum Direction {
	case Up, Down, Left, Right
}

enum HideDirection {
	case Left, Right
}
