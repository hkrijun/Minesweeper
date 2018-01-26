//
//  NewHighScoreViewController.swift
//  Minesweeper
//
//  Created by Henri on 23/01/2018.
//  Copyright © 2018 Koulutus. All rights reserved.
//

import UIKit

class NewHighScoreViewController: UIViewController {
	
 	// -- UI Outlets
	
	@IBOutlet weak var titleText: UILabel!
	@IBOutlet weak var backgroundHighlight: UIImageView!
	
	@IBOutlet weak var scorePosition: PaddedLabel!
	@IBOutlet weak var mapType: PaddedLabel!
	@IBOutlet weak var score: UILabel!
	
	@IBOutlet weak var name: UITextField!
	
	// -- Private vars
	
	private var m_mapType : Statistics.ScoreList = .NormalMap
	private var m_position : Int = 0
	private var m_seconds : Int = 0
	
	// -- Functions
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		titleText.sizeToFit()
		backgroundHighlight.image = GraphicsManager.sharedInstance.highlightGraphic
		
		SetupUI()
	}
	
	func Setup(seconds: Int, position: Int, mapType: Statistics.ScoreList) {
		m_mapType = mapType
		m_position = position
		m_seconds = seconds
	}
	
	private func SetupUI() {
		score.text = Statistics.sharedInstance.Format(secondsToTime: m_seconds)
		scorePosition.text = "#\(m_position + 1)"
		mapType.text = m_mapType.ToString()
	}
	
	@IBAction func continueClicked(sender: AnyObject) {
		if name.text != nil && name.text!.count > 0 {
			Statistics.sharedInstance.AddScore(toList: m_mapType, position: m_position, name: name.text!, seconds: m_seconds)
			self.performSegueToReturnBack(kCATransitionFromLeft)
		}
	}
	
}
