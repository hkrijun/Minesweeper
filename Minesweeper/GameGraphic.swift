//
//  GameGraphic.swift
//  Minesweeper
//
//  Created by Koulutus on 31/10/2017.
//  Copyright © 2017 Koulutus. All rights reserved.
//

import UIKit

class GameGraphic {
	var graph : UIImage?
	
	static let m_tileCornerRadius : CGFloat = 0.2
	static let m_tileMargins : CGFloat = 0 // 0.08
	
	func CreateImage(_ width : Int, height : Int? = nil ) -> UIImage? {
		return nil
	}
	
	init(_ width: Int, height: Int? = nil) {
		graph = CreateImage(width, height: height)
	}
}
