//
//  GraphicsManager.swift
//  Minesweeper
//
//  Created by Koulutus on 17/10/2017.
//  Copyright © 2017 Koulutus. All rights reserved.
//

import UIKit
import Foundation
import UIScreenExtension

class GraphicsManager {
	
	static let sharedInstance = GraphicsManager()
	
	// -- Gameboard graphics
	
	var bombGraphic : UIImage?
	var selectedBlockGraphic : UIImage?
	var bombTileGraphic : [UIImage] = [UIImage]()
	var riddlerGraphic : [UIImage] = [UIImage]()
	var cluedoGraphic : [UIImage] = [UIImage]()
	
	// -- UI graphics
	
	var uiOpenGraphic : UIImage?
	var uiAddFlagGraphic : UIImage?
	var uiRemoveFlagGraphic : UIImage?
	var highlightGraphic : UIImage?
	
	var buttonFlagGraphic : UIImage?
	
	// -- Menu graphics
	
	var menuBombGraphic : UIImage?
	
	// -- Misc
	
	var graphicsFont : String?
	
	var tileSize : Int = 0
	var uiButtonSize : Int = 0
	
	var screenWidth : Int = 0
	var screenHeight : Int = 0
	var screenSize : CGFloat = 0
	
	// -- Properties
	
	var centimetersToPoints : CGFloat {
		get {
			return (UIScreen.pointsPerCentimeter ?? 150)
		}
	}
	
	/// Initialises graphics
	
	func RenderGraphics(_ size: Int) {
		tileSize = size
		uiButtonSize = Int(Float(size) * 1.25)
		
		// -- Game graphics
		
		bombGraphic = BombGraphic(size).graph
		selectedBlockGraphic = SelectedBlockGraphic(size).graph
		
		for blockType in 0..<RiddlerGraphic.BlockType.count.rawValue {
			riddlerGraphic.insert(RiddlerGraphic(size, blockType: blockType,
			                                     backgroundColor: UIColor(hue: 212/360, saturation: 0.73, brightness: 0.78, alpha: 1),
			                                     strokeColor: UIColor(hue: 212/360, saturation: 0.68, brightness: 0.68, alpha: 1)).graph!, at: blockType)
			
			bombTileGraphic.insert(RiddlerGraphic(size, blockType: blockType,
			                                      backgroundColor: UIColor(hue: 350/360.0, saturation: 0.93, brightness: 0.91, alpha: 1),
			                                      strokeColor: UIColor(hue: 350/360.0, saturation: 0.93, brightness: 0.72, alpha: 1)).graph!, at: blockType)
		}
		
		for threat in 0...8 {
			cluedoGraphic.append(CluedoGraphic(size, threat: threat).graph!)
		}
		
		// -- UI graphics
		
		uiOpenGraphic = UIOpenGraphic(uiButtonSize, pointerPosition: .bottom, icon: .shovel).graph
		uiAddFlagGraphic = UIOpenGraphic(uiButtonSize, pointerPosition: .top, icon: .flag).graph
		uiRemoveFlagGraphic = UIOpenGraphic(uiButtonSize, pointerPosition: .top, icon: .flag, subType: .remove).graph
		
		buttonFlagGraphic = UIOpenGraphic(Int(CGFloat(tileSize)), icon: .flag).graph
		
		// -- Menu graphics
		
		highlightGraphic = HighlightGraphic(Int(Float(screenWidth) * 1.0), height: Int(Float(screenHeight) * 1.0)).graph
		menuBombGraphic = BombGraphic(size, drawGlow: false).graph
	}
	
	func SetScreen(width: Int, height: Int) {
		screenWidth = width
		screenHeight = height
		screenSize = Pos(CGFloat(width), CGFloat(height)).Magnitude()
	}
	
	private init() {
		FindGraphicsFont()
	}
	
	/// Called only by constructor
	private func FindGraphicsFont() {
		let fonts : [String] = [ "HelveticaNeue-CondensedBlack", "AvenirNext-Regular", "HelveticaNeue-Thin" ]
		let fontFamilyNames = UIFont.familyNames
		
		graphicsFont = nil
		
		for font in fonts {
			for familyName in fontFamilyNames {
				if UIFont.fontNames(forFamilyName: familyName).contains(font) {
					graphicsFont = font
					break
				}
			}
			
			if graphicsFont != nil {
				break
			}
		}
		
		/*
		let fontFamilyNames = UIFont.familyNames
		for familyName in fontFamilyNames {
		print("------------------------------")
		print("Font Family Name = [\(familyName)]")
		let names = UIFont.fontNames(forFamilyName: familyName )
		print("Font Names = [\(names)]")
		}*/
		
	}

}
